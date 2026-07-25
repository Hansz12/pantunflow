import 'dart:math';

import 'package:csv/csv.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/app_store.dart';
import '../models/pantun.dart';

final Random _random = Random();

Future<void> loadPantunFromCsv() async {
  try {
    final String rawData = await rootBundle.loadString(
      'assets/pantun_data.csv',
    );

    final List<List<dynamic>> rows =
    const CsvToListConverter().convert(rawData);

    if (rows.length <= 1) {
      debugPrint('CSV pantun kosong atau hanya mempunyai header.');
      return;
    }

    final List<Pantun> loadedPantun = <Pantun>[];

    for (int i = 1; i < rows.length; i++) {
      final List<dynamic> row = rows[i];

      // Pastikan row mempunyai sekurang-kurangnya 5 column:
      // id, text, theme, mood, location
      if (row.length < 5) {
        debugPrint(
          'CSV row ${i + 1} diabaikan kerana column tidak lengkap.',
        );
        continue;
      }

      final String id = row[0].toString().trim();
      final String text = row[1].toString().trim();
      final String theme = row[2].toString().trim();
      final String mood = row[3].toString().trim();
      final String location = row[4].toString().trim();

      if (text.isEmpty) {
        debugPrint(
          'CSV row ${i + 1} diabaikan kerana teks pantun kosong.',
        );
        continue;
      }

      loadedPantun.add(
        Pantun(
          id: id.isEmpty ? 'csv-$i' : id,
          text: text,
          theme: theme,
          mood: mood,
          location: location,
          saved: false,
        ),
      );
    }

    AppStore.collection
      ..clear()
      ..addAll(loadedPantun);

    debugPrint(
      '${AppStore.collection.length} pantun berjaya dimuatkan dari CSV.',
    );
  } catch (error, stackTrace) {
    debugPrint('RALAT LOAD CSV: $error');
    debugPrintStack(stackTrace: stackTrace);

    rethrow;
  }
}

Pantun recommendPantun() {
  if (AppStore.collection.isEmpty) {
    return _generateLocalFallback(
      'indah bahasa',
      'Nasihat',
      'Tenang',
      '',
    );
  }

  final String preferredTheme =
  AppStore.preferredTheme.trim().toLowerCase();

  final List<Pantun> matches = AppStore.collection.where(
        (Pantun pantun) {
      return pantun.theme.trim().toLowerCase() == preferredTheme;
    },
  ).toList();

  final List<Pantun> source =
  matches.isNotEmpty ? matches : AppStore.collection;

  return source[_random.nextInt(source.length)];
}

Future<Pantun> generatePantun(
    String keyword,
    String theme,
    String mood,
    String location,
    ) async {
  final String cleanKeyword = keyword.trim();
  final String cleanTheme = theme.trim();
  final String cleanMood = mood.trim();
  final String cleanLocation = location.trim();

  if (cleanKeyword.isEmpty) {
    throw ArgumentError(
      'Kata kunci diperlukan untuk menjana pantun.',
    );
  }

  try {
    final GenerativeModel model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
      generationConfig: GenerationConfig(
        temperature: 0.85,
        topP: 0.90,
        maxOutputTokens: 220,
      ),
    );

    final String locationInstruction = cleanLocation.isEmpty
        ? 'Jangan masukkan lokasi atau nama majlis.'
        : 'Masukkan lokasi atau majlis "$cleanLocation" secara semula jadi jika sesuai.';

    final String prompt = '''
Anda ialah pakar pantun tradisional Melayu.

Cipta SATU pantun empat kerat berdasarkan maklumat berikut:

Tema: $cleanTheme
Mood: $cleanMood
Kata kunci atau cerita: $cleanKeyword
Lokasi atau majlis: ${cleanLocation.isEmpty ? 'Tiada' : cleanLocation}

Peraturan wajib:
1. Hasil mesti tepat EMPAT baris.
2. Baris pertama dan kedua ialah pembayang.
3. Baris ketiga dan keempat ialah maksud.
4. Gunakan Bahasa Melayu yang semula jadi dan gramatis.
5. Gunakan gaya pantun tradisional Melayu.
6. Cuba gunakan pola rima silang ABAB.
7. Setiap baris hendaklah ringkas dan mudah dibaca.
8. Tema, mood dan kata kunci mesti jelas dalam maksud.
9. $locationInstruction
10. Jangan beri tajuk, penerangan, nombor, bullet, markdown atau tanda petik.
11. Berikan teks pantun sahaja.

Contoh format output:
Baris pertama
Baris kedua
Baris ketiga
Baris keempat
''';

    final GenerateContentResponse response =
    await model.generateContent(
      <Content>[
        Content.text(prompt),
      ],
    );

    final String? rawText = response.text;

    if (rawText == null || rawText.trim().isEmpty) {
      throw const PantunGenerationException(
        'Respons AI kosong.',
      );
    }

    final String cleanedPantun = _cleanGeneratedPantun(
      rawText,
    );

    final List<String> lines = _extractPantunLines(
      cleanedPantun,
    );

    if (lines.length != 4) {
      throw PantunGenerationException(
        'AI menghasilkan ${lines.length} baris, bukan empat baris.',
      );
    }

    return Pantun(
      id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
      text: lines.join('\n'),
      theme: cleanTheme,
      mood: cleanMood,
      location: cleanLocation,
      saved: false,
    );
  } catch (error, stackTrace) {
    debugPrint('RALAT GEMINI AI: $error');
    debugPrintStack(stackTrace: stackTrace);

    // Fallback tempatan supaya aplikasi masih boleh digunakan.
    return _generateLocalFallback(
      cleanKeyword,
      cleanTheme,
      cleanMood,
      cleanLocation,
    );
  }
}

String _cleanGeneratedPantun(String value) {
  String cleaned = value.trim();

  cleaned = cleaned
      .replaceAll('```text', '')
      .replaceAll('```markdown', '')
      .replaceAll('```', '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .trim();

  return cleaned;
}

List<String> _extractPantunLines(String value) {
  final List<String> lines = value
      .split('\n')
      .map((String line) {
    return line
        .replaceFirst(
      RegExp(r'^\s*(?:\d+[\.\)]|[-•*])\s*'),
      '',
    )
        .trim();
  })
      .where((String line) => line.isNotEmpty)
      .toList();

  if (lines.length == 4) {
    return lines;
  }

  // Ada model yang menggabungkan baris menggunakan slash.
  if (lines.length == 1 && lines.first.contains('/')) {
    return lines.first
        .split('/')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  return lines;
}

Pantun _generateLocalFallback(
    String keyword,
    String theme,
    String mood,
    String location,
    ) {
  final String idea = keyword.trim().isEmpty
      ? 'indah bahasa'
      : keyword.trim();

  final String place = location.trim();

  final List<List<String>> pembayangOptions = <List<String>>[
    <String>[
      'Bunga melati harum mewangi,',
      'Tumbuh mekar di tepi perigi;',
    ],
    <String>[
      'Burung kenari terbang tinggi,',
      'Hinggap sebentar di pohon jati;',
    ],
    <String>[
      'Ombak beralun di tepi pantai,',
      'Cahaya bulan menyinari titi;',
    ],
    <String>[
      'Pergi ke pekan membeli delima,',
      'Singgah sebentar di hujung desa;',
    ],
  ];

  final List<String> pembayang =
  pembayangOptions[_random.nextInt(pembayangOptions.length)];

  final String thirdLine = _buildFallbackThirdLine(
    idea,
    mood,
  );

  final String fourthLine = place.isEmpty
      ? _buildFallbackFourthLine(theme)
      : 'Kenangan indah di $place kekal di hati.';

  return Pantun(
    id: 'local-${DateTime.now().millisecondsSinceEpoch}',
    text: <String>[
      pembayang[0],
      pembayang[1],
      thirdLine,
      fourthLine,
    ].join('\n'),
    theme: theme,
    mood: mood,
    location: location,
    saved: false,
  );
}

String _buildFallbackThirdLine(
    String keyword,
    String mood,
    ) {
  switch (mood.toLowerCase()) {
    case 'gembira':
      return '$keyword membawa hati berseri,';

    case 'sayu':
      return '$keyword mengusik rasa di hati,';

    case 'tenang':
    default:
      return '$keyword tersimpan damai di hati,';
  }
}

String _buildFallbackFourthLine(String theme) {
  switch (theme.toLowerCase()) {
    case 'cinta':
      return 'Kasih yang tulus kekal abadi.';

    case 'persahabatan':
      return 'Ikatan sahabat sentiasa abadi.';

    case 'nasihat':
      return 'Jadikan pedoman sepanjang hari.';

    default:
      return 'Indah dikenang sepanjang hari.';
  }
}

class PantunGenerationException implements Exception {
  final String message;

  const PantunGenerationException(this.message);

  @override
  String toString() {
    return message;
  }
}