import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/pantun.dart';

class HistoryStore {
  // =========================================================
  // FIREBASE
  // =========================================================

  static FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  static User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  static CollectionReference<Map<String, dynamic>>?
  get _historyReference {
    final User? user = currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('generationHistory');
  }

  // =========================================================
  // HISTORY COLLECTION
  // =========================================================

  static List<Pantun> history = <Pantun>[];

  static final ValueNotifier<int> historyNotifier =
  ValueNotifier<int>(0);

  static bool _isLoading = false;

  static const int maximumHistoryItems = 50;

  static void notifyHistoryChanged() {
    historyNotifier.value++;
  }

  // =========================================================
  // DOCUMENT ID
  // =========================================================

  /// Menghasilkan ID Firestore yang tetap berdasarkan teks pantun.
  ///
  /// Pantun dengan teks yang sama akan menggunakan document ID
  /// yang sama. Ini mengelakkan duplicate history.
  static String _createHistoryDocumentId(Pantun pantun) {
    final String normalizedText = pantun.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    final int hash = _stableTextHash(normalizedText);

    return 'history_$hash';
  }

  /// Stable FNV-1a hash.
  ///
  /// Berbeza daripada String.hashCode kerana nilai ini kekal sama
  /// walaupun aplikasi ditutup dan dibuka semula.
  static int _stableTextHash(String value) {
    int hash = 0x811C9DC5;

    for (final int character in value.codeUnits) {
      hash ^= character;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash;
  }

  // =========================================================
  // CHECK HISTORY
  // =========================================================

  static bool containsPantun(Pantun pantun) {
    final String targetText = _normalizeText(
      pantun.text,
    );

    return history.any(
          (Pantun item) {
        return _normalizeText(item.text) == targetText;
      },
    );
  }

  static String _normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // =========================================================
  // SAVE GENERATED PANTUN
  // =========================================================

  static Future<void> saveHistory(
      Pantun pantun,
      ) async {
    final User? user = currentUser;

    final CollectionReference<Map<String, dynamic>>?
    reference = _historyReference;

    if (user == null || reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    if (pantun.text.trim().isEmpty) {
      throw ArgumentError(
        'Teks pantun tidak boleh kosong.',
      );
    }

    final Pantun historyPantun = pantun.copyWith(
      saved: false,
      generatedAt: DateTime.now(),
    );

    final String documentId =
    _createHistoryDocumentId(historyPantun);

    await reference.doc(documentId).set(
      <String, dynamic>{
        ...historyPantun.toJson(),

        // History bukan favourite.
        'saved': false,

        'userId': user.uid,
        'historyDocumentId': documentId,

        // Jika pantun sama dijana semula,
        // generatedAt akan dikemas kini.
        'generatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    _insertOrMoveToTop(historyPantun);

    notifyHistoryChanged();

    await _enforceHistoryLimit();

    debugPrint(
      'Pantun dimasukkan ke sejarah: $documentId',
    );
  }

  // =========================================================
  // INSERT OR MOVE DUPLICATE TO TOP
  // =========================================================

  static void _insertOrMoveToTop(
      Pantun pantun,
      ) {
    final String targetText = _normalizeText(
      pantun.text,
    );

    history.removeWhere(
          (Pantun item) {
        return _normalizeText(item.text) == targetText;
      },
    );

    history.insert(
      0,
      pantun.copyWith(saved: false),
    );

    if (history.length > maximumHistoryItems) {
      history = history
          .take(maximumHistoryItems)
          .toList();
    }
  }

  // =========================================================
  // LOAD HISTORY FROM FIRESTORE
  // =========================================================

  static Future<void> loadHistory() async {
    if (_isLoading) {
      return;
    }

    final User? user = currentUser;

    final CollectionReference<Map<String, dynamic>>?
    reference = _historyReference;

    if (user == null || reference == null) {
      history = <Pantun>[];
      notifyHistoryChanged();

      debugPrint(
        'HISTORY LOAD: Pengguna belum log masuk.',
      );

      return;
    }

    _isLoading = true;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await reference
          .orderBy(
        'generatedAt',
        descending: true,
      )
          .limit(maximumHistoryItems)
          .get();

      final List<Pantun> loadedHistory = <Pantun>[];
      final Set<String> existingTexts = <String>{};

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>>
      document in snapshot.docs) {
        final Map<String, dynamic> data =
        document.data();

        final Pantun pantun = Pantun.fromJson(
          <String, dynamic>{
            ...data,
            'id': data['id']?.toString() ?? document.id,
            'saved': false,
            'generatedAt': (data['generatedAt'] as Timestamp?)?.millisecondsSinceEpoch,
          },
        ).copyWith(
          saved: false,
        );

        final String normalizedText =
        _normalizeText(pantun.text);

        if (normalizedText.isEmpty) {
          continue;
        }

        // Perlindungan tambahan jika Firestore
        // pernah mempunyai data duplicate.
        if (existingTexts.contains(normalizedText)) {
          continue;
        }

        existingTexts.add(normalizedText);
        loadedHistory.add(pantun);
      }

      history = loadedHistory;

      notifyHistoryChanged();

      debugPrint(
        'HISTORY LOAD COMPLETE: '
            '${history.length} pantun.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'HISTORY LOAD ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // =========================================================
  // DELETE ONE HISTORY
  // =========================================================

  static Future<void> deleteHistory(
      Pantun pantun,
      ) async {
    final CollectionReference<Map<String, dynamic>>?
    reference = _historyReference;

    if (reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    final String documentId =
    _createHistoryDocumentId(pantun);

    await reference.doc(documentId).delete();

    final String targetText = _normalizeText(
      pantun.text,
    );

    history.removeWhere(
          (Pantun item) {
        return _normalizeText(item.text) == targetText;
      },
    );

    notifyHistoryChanged();

    debugPrint(
      'Pantun dipadam daripada sejarah: '
          '$documentId',
    );
  }

  // =========================================================
  // CLEAR ALL HISTORY
  // =========================================================

  static Future<void> clearAllHistory() async {
    final CollectionReference<Map<String, dynamic>>?
    reference = _historyReference;

    if (reference == null) {
      throw StateError(
        'Pengguna belum log masuk.',
      );
    }

    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await reference.limit(100).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final WriteBatch batch = _firestore.batch();

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>>
      document in snapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }

    history.clear();

    notifyHistoryChanged();

    debugPrint(
      'Semua sejarah pantun telah dipadam.',
    );
  }

  // =========================================================
  // LIMIT HISTORY TO 50 ITEMS
  // =========================================================

  static Future<void> _enforceHistoryLimit() async {
    final CollectionReference<Map<String, dynamic>>?
    reference = _historyReference;

    if (reference == null) {
      return;
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
      await reference
          .orderBy(
        'generatedAt',
        descending: true,
      )
          .get();

      if (snapshot.docs.length <=
          maximumHistoryItems) {
        return;
      }

      final List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      documentsToDelete = snapshot.docs
          .skip(maximumHistoryItems)
          .toList();

      final WriteBatch batch = _firestore.batch();

      for (final QueryDocumentSnapshot<
          Map<String, dynamic>>
      document in documentsToDelete) {
        batch.delete(document.reference);
      }

      await batch.commit();

      debugPrint(
        '${documentsToDelete.length} sejarah lama '
            'dipadam kerana melebihi had '
            '$maximumHistoryItems.',
      );
    } catch (error, stackTrace) {
      // Gagal membersihkan sejarah lama tidak sepatutnya
      // menyebabkan proses generate pantun gagal.
      debugPrint(
        'HISTORY LIMIT ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =========================================================
  // LOCAL SESSION
  // =========================================================

  static void clearLocalHistory() {
    history.clear();
    notifyHistoryChanged();
  }
}