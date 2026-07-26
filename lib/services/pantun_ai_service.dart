import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_key.dart';

class PantunAiService {
  PantunAiService._();

  static Future<String> generatePantun({
    required String story,
    required String mood,
    required String theme,
    String? location,
  }) async {
    final cleanStory = story.trim();

    if (cleanStory.isEmpty) {
      throw ArgumentError('Cerita atau kata kunci tidak boleh kosong.');
    }

    final locationInstruction = location != null && location.trim().isNotEmpty
        ? 'Lokasi atau majlis: ${location.trim()}'
        : 'Lokasi atau majlis: Tidak dinyatakan';

    final prompt = '''
Anda ialah pakar bahasa dan kesusasteraan Melayu.

Hasilkan SATU pantun Melayu empat kerat berdasarkan maklumat berikut:

Cerita atau kata kunci: $cleanStory
Mood: $mood
Tema: $theme
$locationInstruction

Syarat wajib:
1. Pantun mesti mempunyai tepat empat baris.
2. Dua baris pertama ialah pembayang.
3. Dua baris terakhir ialah maksud.
4. Gunakan bahasa Melayu yang semula jadi dan mudah difahami.
5. Pantun mesti sesuai dengan tema dan mood pengguna.
6. Cuba gunakan pola rima akhir ABAB.
7. Jangan beri tajuk, penerangan, nombor atau nota tambahan.
8. Pulangkan empat baris pantun sahaja.
''';

    try {
      final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/'
        'models/gemini-3.6-flash:generateContent'
        '?key=${ApiKey.geminiApiKey}',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 2048,
            'thinkingConfig': {
              'thinkingLevel': 'low',
            },
          }
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Gemini Error (${response.statusCode}): ${response.body}",
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? pantun = data["candidates"]?[0]["content"]?["parts"]?[0]["text"]?.trim();

      if (pantun == null || pantun.isEmpty) {
        throw Exception('AI tidak menghasilkan pantun.');
      }

      return pantun;
    } catch (error) {
      debugPrint('GEMINI AI ERROR: $error');
      throw Exception('Gagal menjana pantun: $error');
    }
  }
}
