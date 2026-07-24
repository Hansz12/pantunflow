import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/app_store.dart';
import '../models/pantun.dart';

const String _apiKey = 'AQ.Ab8RN6LXUgSxKYAuwMfZcUqibVa7KtiKeDSYy1Kbo6sAbXUoAg';

Future<void> loadPantunFromCsv() async {
  try {
    final rawData = await rootBundle.loadString('assets/pantun_data.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    
    AppStore.collection.clear();

    for (int i = 1; i < listData.length; i++) {
      var row = listData[i];
      AppStore.collection.add(Pantun(
        id: row[0].toString(),
        text: row[1].toString(),
        theme: row[2].toString(),
        mood: row[3].toString(),
        location: row[4].toString(),
        saved: false,
      ));
    }
  } catch (e) {
    debugPrint("Error loading CSV: $e");
  }
}

Pantun recommendPantun() {
  final matches = AppStore.collection
      .where((pantun) => pantun.theme == AppStore.preferredTheme)
      .toList();
  return matches.isEmpty ? AppStore.collection.first : matches.first;
}

Future<Pantun> generatePantun(
  String keyword,
  String theme,
  String mood,
  String location,
) async {
  try {
    // Cuba panggil Gemini AI
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
Cipta sebuah pantun empat kerat tradisional Melayu dengan syarat berikut:
- Tema: $theme
- Mood: $mood
- Kata kunci: ${keyword.isEmpty ? 'Tiada' : keyword}
- Lokasi: ${location.isEmpty ? 'Tiada' : location}
Hanya berikan teks pantun sahaja tanpa sebarang pengenalan.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final generatedText = response.text?.trim();

    if (generatedText != null && generatedText.isNotEmpty) {
      return Pantun(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: generatedText,
        theme: theme,
        mood: mood,
        location: location,
        saved: false,
      );
    }
    throw Exception('Respons AI kosong');
    
  } catch (e) {
    debugPrint("AI bypass ke local fallback sebab ralat: $e");
    // Jika AI gagal/ralat, ia automatik guna sistem tempatan yang lancar & takkan error!
    return _generateLocalFallback(keyword, theme, mood, location);
  }
}

Pantun _generateLocalFallback(
  String keyword,
  String theme,
  String mood,
  String location,
) {
  final place = location.trim().isEmpty ? 'Malaysia' : location.trim();
  final idea = keyword.trim().isEmpty ? 'indah bahasa' : keyword.trim();
  
  final pembayangList = [
    'Bunga melati harum mewangi,\nTumbuh segar di tepi kali;',
    'Burung kenari terbang tinggi,\nHinggap sebentar di pohon jati;',
    'Ombak beralun di tepi pantai,\nCahaya bulan jatuh ke bumi;',
  ];
  final pembayang = pembayangList[Random().nextInt(pembayangList.length)];

  return Pantun(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    text: '$pembayang\n$idea membawa rindu dihati,\nKenangan manis di $place abadi.',
    theme: theme,
    mood: mood,
    location: location,
    saved: false,
  );
}