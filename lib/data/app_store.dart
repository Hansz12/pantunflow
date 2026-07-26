import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/pantun.dart';

class AppStore {
  static final ValueNotifier<String> nameNotifier =
  ValueNotifier<String>('User');

  static String get name => nameNotifier.value;

  static set name(String value) {
    final String cleanedName = value.trim();

    nameNotifier.value =
    cleanedName.isEmpty ? 'User' : cleanedName;
  }

  static final ValueNotifier<String> preferredThemeNotifier =
  ValueNotifier<String>(
    'Peribahasa & Kiasan',
  );

  static String get preferredTheme =>
      preferredThemeNotifier.value;

  static set preferredTheme(String value) {
    final String cleanedTheme = value.trim();

    preferredThemeNotifier.value = cleanedTheme.isEmpty
        ? 'Peribahasa & Kiasan'
        : cleanedTheme;
  }

  static List<Pantun> collection = <Pantun>[];

  static final ValueNotifier<int> collectionNotifier =
  ValueNotifier<int>(0);

  static void notifyCollectionChanged() {
    collectionNotifier.value++;
  }

  static Future<void> loadPantunFromAsset() async {
    if (collection.isNotEmpty) {
      return;
    }

    try {
      final String response = await rootBundle.loadString(
        'assets/pantun_data.json',
      );

      final dynamic decodedJson = jsonDecode(response);

      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException(
          'Format utama JSON bukan objek yang sah.',
        );
      }

      final dynamic rawData =
      decodedJson['data_klasifikasi_pantun'];

      if (rawData is! List<dynamic>) {
        collection = <Pantun>[];

        notifyCollectionChanged();

        debugPrint(
          'Kunci data_klasifikasi_pantun tidak mengandungi senarai.',
        );

        return;
      }

      collection = rawData
          .whereType<Map<String, dynamic>>()
          .map(Pantun.fromJson)
          .toList();

      notifyCollectionChanged();

      debugPrint(
        'Berjaya memuatkan ${collection.length} pantun daripada JSON.',
      );
    } catch (error, stackTrace) {
      collection = <Pantun>[];

      notifyCollectionChanged();

      debugPrint(
        'Ralat semasa membaca pantun_data.json: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }
}