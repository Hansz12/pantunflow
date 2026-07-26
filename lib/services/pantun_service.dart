import 'dart:convert';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../config/api_key.dart';
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

  final List<Pantun> candidates =
      List<Pantun>.from(AppStore.collection);

  candidates.sort(
    (Pantun a, Pantun b) {
      int scoreA = 0;
      int scoreB = 0;

      // ==========================
      // Theme Preference
      // ==========================

      scoreA +=
          AppStore.getThemeScore(a.theme) * 3;

      scoreB +=
          AppStore.getThemeScore(b.theme) * 3;

      // ==========================
      // Mood Preference
      // ==========================

      scoreA +=
          AppStore.getMoodScore(a.mood) * 2;

      scoreB +=
          AppStore.getMoodScore(b.mood) * 2;

      // ==========================
      // Preferred Theme
      // ==========================

      if (a.theme ==
          AppStore.preferredTheme) {
        scoreA += 2;
      }

      if (b.theme ==
          AppStore.preferredTheme) {
        scoreB += 2;
      }

      return scoreB.compareTo(scoreA);
    },
  );

  // Ambil antara recommendation terbaik supaya
  // tidak sentiasa keluar pantun yang sama.

  final int limit =
      candidates.length < 8
          ? candidates.length
          : 8;

  return candidates[
      _random.nextInt(limit)];
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

  debugPrint("========== PROMPT ==========");
  debugPrint(prompt);

  try {
    final Uri url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/'
      'models/gemini-3.6-flash:generateContent'
      '?key=${ApiKey.geminiApiKey}',
    );

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, dynamic>{
          'contents': <Map<String, dynamic>>[
            <String, dynamic>{
              'parts': <Map<String, String>>[
                <String, String>{
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': <String, dynamic>{
            'maxOutputTokens': 2048,
            'thinkingConfig': <String, dynamic>{
              'thinkingLevel': 'low',
            },
          },
        },
      ),
    );

    debugPrint("HTTP Status: ${response.statusCode}");
    debugPrint(response.body);

    if (response.statusCode != 200) {
      throw PantunGenerationException(
        "Gemini Error (${response.statusCode})\n${response.body}",
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    final String rawText = json["candidates"][0]["content"]["parts"][0]["text"];

    debugPrint("================ RAW GEMINI ================");
    debugPrint(rawText);
    debugPrint("===========================================");

    final String cleanedPantun = _cleanGeneratedPantun(rawText);

    final List<String> lines = _extractPantunLines(cleanedPantun);

    if (lines.length < 4) {
      return _generateLocalFallback(
        cleanKeyword,
        cleanTheme,
        cleanMood,
        cleanLocation,
      );
    }

    final List<String> finalLines = lines.take(4).toList();

    return Pantun(
      id: "ai-${DateTime.now().millisecondsSinceEpoch}",
      text: finalLines.join("\n"),
      theme: cleanTheme,
      mood: cleanMood,
      location: cleanLocation,
      saved: false,
    );
  } catch (e, s) {
    debugPrint("========== GEMINI ERROR ==========");
    debugPrint(e.toString());
    debugPrintStack(stackTrace: s);
    debugPrint("==================================");

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
  final String idea = keyword.trim().isEmpty ? 'indah bahasa' : keyword.trim();

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
