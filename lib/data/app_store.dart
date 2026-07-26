import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pantun.dart';

class AppStore {
  // =========================================================
  // USER PROFILE
  // =========================================================

  static final ValueNotifier<String> nameNotifier =
  ValueNotifier<String>('User');

  static String get name => nameNotifier.value;

  static set name(String value) {
    final String cleanedName = value.trim();

    nameNotifier.value =
    cleanedName.isEmpty ? 'User' : cleanedName;
  }

  // =========================================================
  // USER PREFERRED THEME
  // =========================================================

  static final ValueNotifier<String> preferredThemeNotifier =
  ValueNotifier<String>(
    'Peribahasa & Kiasan',
  );

  static String get preferredTheme =>
      preferredThemeNotifier.value;

  static set preferredTheme(String value) {
    final String cleanedTheme = value.trim();

    preferredThemeNotifier.value =
    cleanedTheme.isEmpty
        ? 'Peribahasa & Kiasan'
        : cleanedTheme;
  }

  // =========================================================
  // FIREBASE
  // =========================================================

  static FirebaseFirestore get _firestore =>
      FirebaseFirestore.instance;

  static User? get currentUser =>
      FirebaseAuth.instance.currentUser;

  static CollectionReference<Map<String, dynamic>>?
  get _savedPantunReference {
    final User? user = currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedPantun');
  }

  // =========================================================
  // PANTUN COLLECTION
  // =========================================================

  static List<Pantun> collection = <Pantun>[];

  static final ValueNotifier<int> collectionNotifier =
  ValueNotifier<int>(0);

  static bool _isLoadingDataset = false;
  static bool _datasetLoaded = false;

  static void notifyCollectionChanged() {
    collectionNotifier.value++;
  }

  // =========================================================
  // LOCAL STORAGE PERSISTENCE
  // =========================================================

  static const String _savedPantunKey = 'pantunflow_saved_pantun';

  static Future<void> saveCollectionToStorage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> savedItems = collection
        .where((Pantun pantun) => pantun.saved)
        .map((Pantun pantun) => pantun.toJson())
        .toList();

    final String encodedData = jsonEncode(savedItems);

    await preferences.setString(
      _savedPantunKey,
      encodedData,
    );

    debugPrint(
      '${savedItems.length} pantun disimpan ke storan tempatan.',
    );
  }

  static Future<void> loadSavedCollection() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();

      final String? encodedData = preferences.getString(_savedPantunKey);

      if (encodedData == null || encodedData.trim().isEmpty) {
        return;
      }

      final dynamic decodedData = jsonDecode(encodedData);

      if (decodedData is! List<dynamic>) {
        return;
      }

      final List<Pantun> savedItems = decodedData
          .whereType<Map<String, dynamic>>()
          .map(Pantun.fromJson)
          .toList();

      for (final Pantun savedPantun in savedItems) {
        final int existingIndex = collection.indexWhere(
          (Pantun pantun) => pantun.id == savedPantun.id,
        );

        if (existingIndex >= 0) {
          collection[existingIndex] = savedPantun.copyWith(saved: true);
        } else {
          collection.insert(
            0,
            savedPantun.copyWith(saved: true),
          );
        }
      }

      rebuildInteractionScores();
      notifyCollectionChanged();

      debugPrint(
        '${savedItems.length} pantun berjaya dipulihkan.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Ralat memuatkan koleksi tersimpan: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =========================================================
  // PERSONALIZATION SCORES
  // =========================================================

  static final Map<String, int> themeScore =
  <String, int>{};

  static final Map<String, int> moodScore =
  <String, int>{};

  static void recordInteraction(Pantun pantun) {
    final String theme = pantun.theme.trim();
    final String mood = pantun.mood.trim();

    if (theme.isNotEmpty) {
      themeScore[theme] =
          (themeScore[theme] ?? 0) + 1;
    }

    if (mood.isNotEmpty) {
      moodScore[mood] =
          (moodScore[mood] ?? 0) + 1;
    }

    notifyCollectionChanged();

    debugPrint(
      'Interaksi direkodkan: '
          'theme=$theme, mood=$mood',
    );

    debugPrint('Theme scores: $themeScore');
    debugPrint('Mood scores: $moodScore');
  }

  static void removeInteraction(Pantun pantun) {
    final String theme = pantun.theme.trim();
    final String mood = pantun.mood.trim();

    if (theme.isNotEmpty &&
        themeScore.containsKey(theme)) {
      final int updatedScore =
          (themeScore[theme] ?? 0) - 1;

      if (updatedScore <= 0) {
        themeScore.remove(theme);
      } else {
        themeScore[theme] = updatedScore;
      }
    }

    if (mood.isNotEmpty &&
        moodScore.containsKey(mood)) {
      final int updatedScore =
          (moodScore[mood] ?? 0) - 1;

      if (updatedScore <= 0) {
        moodScore.remove(mood);
      } else {
        moodScore[mood] = updatedScore;
      }
    }

    notifyCollectionChanged();
  }

  static void rebuildInteractionScores() {
    themeScore.clear();
    moodScore.clear();

    for (final Pantun pantun in collection) {
      if (!pantun.saved) {
        continue;
      }

      final String theme = pantun.theme.trim();
      final String mood = pantun.mood.trim();

      if (theme.isNotEmpty) {
        themeScore[theme] = (themeScore[theme] ?? 0) + 1;
      }

      if (mood.isNotEmpty) {
        moodScore[mood] = (moodScore[mood] ?? 0) + 1;
      }
    }
  }

  static int getThemeScore(String theme) {
    return themeScore[theme.trim()] ?? 0;
  }

  static int getMoodScore(String mood) {
    return moodScore[mood.trim()] ?? 0;
  }

  static String get dominantTheme {
    if (themeScore.isEmpty) {
      return preferredTheme;
    }

    return themeScore.entries.reduce(
          (
          MapEntry<String, int> current,
          MapEntry<String, int> next,
          ) {
        return next.value > current.value
            ? next
            : current;
      },
    ).key;
  }

  static String get dominantMood {
    if (moodScore.isEmpty) {
      return 'Tenang';
    }

    return moodScore.entries.reduce(
          (
          MapEntry<String, int> current,
          MapEntry<String, int> next,
          ) {
        return next.value > current.value
            ? next
            : current;
      },
    ).key;
  }

  static int get savedPantunCount {
    return collection
        .where(
          (Pantun pantun) => pantun.saved,
    )
        .length;
  }

  // =========================================================
  // FIRESTORE DOCUMENT ID
  // =========================================================

  static String _getFirestoreDocumentId(
      Pantun pantun,
      ) {
    final String originalId =
    pantun.id.trim();

    if (originalId.isNotEmpty) {
      return originalId.replaceAll('/', '_');
    }

    final String textCode =
    pantun.text.hashCode.abs().toString();

    return 'pantun_$textCode';
  }

  // =========================================================
  // SAVE PANTUN TO FIRESTORE
  // =========================================================

  static Future<void> savePantunToFirebase(
      Pantun pantun,
      ) async {
    final User? user = currentUser;

    final CollectionReference<Map<String, dynamic>>?
    reference = _savedPantunReference;

    if (user == null || reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    final Pantun savedPantun =
    pantun.copyWith(
      saved: true,
    );

    final String documentId =
    _getFirestoreDocumentId(savedPantun);

    await reference.doc(documentId).set(
      <String, dynamic>{
        ...savedPantun.toJson(),
        'saved': true,
        'userId': user.uid,
        'savedAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    debugPrint(
      'Pantun disimpan ke Firestore: '
          '$documentId',
    );
  }

  // =========================================================
  // UPDATE PANTUN IN FIRESTORE
  // =========================================================

  static Future<void> updatePantunInFirebase(
      Pantun pantun,
      ) async {
    final User? user = currentUser;

    final CollectionReference<Map<String, dynamic>>?
    reference = _savedPantunReference;

    if (user == null || reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    final String documentId =
    _getFirestoreDocumentId(pantun);

    await reference.doc(documentId).set(
      <String, dynamic>{
        ...pantun.toJson(),
        'saved': true,
        'userId': user.uid,
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    debugPrint(
      'Pantun dikemas kini dalam Firestore: '
          '$documentId',
    );
  }

  // =========================================================
  // DELETE PANTUN FROM FIRESTORE
  // =========================================================

  static Future<void> removePantunFromFirebase(
      Pantun pantun,
      ) async {
    final CollectionReference<Map<String, dynamic>>?
    reference = _savedPantunReference;

    if (reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    final String documentId =
    _getFirestoreDocumentId(pantun);

    await reference
        .doc(documentId)
        .delete();

    debugPrint(
      'Pantun dibuang daripada Firestore: '
          '$documentId',
    );
  }

  // =========================================================
  // LOAD SAVED PANTUN FROM FIRESTORE
  // =========================================================

  static Future<void> loadSavedPantunFromFirebase() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint(
        'FIRESTORE LOAD: User belum login.',
      );
      return;
    }

    try {
      debugPrint(
        'FIRESTORE LOAD UID: ${user.uid}',
      );

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('savedPantun')
              .get();

      debugPrint(
        'FIRESTORE DOCUMENT COUNT: '
        '${snapshot.docs.length}',
      );

      // Reset status saved dataset lokal dahulu.
      for (final Pantun pantun in collection) {
        pantun.saved = false;
      }

      for (final QueryDocumentSnapshot<Map<String, dynamic>> document
          in snapshot.docs) {
        final Map<String, dynamic> data = document.data();

        debugPrint(
          'FIRESTORE DOCUMENT: '
          '${document.id} -> $data',
        );

        final Pantun savedPantun = Pantun.fromJson(
          <String, dynamic>{
            ...data,
            'id': data['id']?.toString() ?? document.id,
            'saved': true,
          },
        );

        final int existingIndex = collection.indexWhere(
          (Pantun pantun) => pantun.id == savedPantun.id,
        );

        if (existingIndex >= 0) {
          collection[existingIndex] = savedPantun.copyWith(
            saved: true,
          );
        } else {
          collection.insert(
            0,
            savedPantun.copyWith(
              saved: true,
            ),
          );
        }
      }

      rebuildInteractionScores();
      notifyCollectionChanged();

      debugPrint(
        'FIRESTORE LOAD COMPLETE: '
        '$savedPantunCount saved pantun.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'FIRESTORE LOAD ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =========================================================
  // LOAD LOCAL PANTUN DATASET
  // =========================================================

  static Future<void>
  loadPantunFromAsset() async {
    if (_isLoadingDataset) {
      return;
    }

    if (_datasetLoaded) {
      await loadSavedPantunFromFirebase();
      return;
    }

    _isLoadingDataset = true;

    try {
      final String response =
      await rootBundle.loadString(
        'assets/pantun_data.json',
      );

      final dynamic decodedJson =
      jsonDecode(response);

      if (decodedJson
      is! Map<String, dynamic>) {
        throw const FormatException(
          'Format utama JSON bukan objek yang sah.',
        );
      }

      final dynamic rawData =
      decodedJson[
      'data_klasifikasi_pantun'];

      if (rawData is! List<dynamic>) {
        collection = <Pantun>[];

        _datasetLoaded = true;

        await loadSavedPantunFromFirebase();

        notifyCollectionChanged();

        debugPrint(
          'Kunci data_klasifikasi_pantun '
              'tidak mengandungi senarai.',
        );

        return;
      }

      collection = rawData
          .whereType<Map<String, dynamic>>()
          .map(Pantun.fromJson)
          .toList();

      _datasetLoaded = true;

      await loadSavedPantunFromFirebase();

      notifyCollectionChanged();

      debugPrint(
        'Berjaya memuatkan '
            '${collection.length} pantun '
            'daripada JSON.',
      );
    } catch (error, stackTrace) {
      collection = <Pantun>[];

      _datasetLoaded = false;

      notifyCollectionChanged();

      debugPrint(
        'Ralat semasa membaca '
            'pantun_data.json: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      _isLoadingDataset = false;
    }
  }

  // =========================================================
  // CLEAR LOCAL SESSION
  // =========================================================

  static void clearUserSessionData() {
    themeScore.clear();
    moodScore.clear();

    for (final Pantun pantun in collection) {
      pantun.saved = false;
    }

    notifyCollectionChanged();
  }
}