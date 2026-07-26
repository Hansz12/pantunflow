import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:intl/intl.dart';

import '../data/app_store.dart';
import '../data/history_store.dart';
import '../models/pantun.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  int _selectedTab = 0;

  List<Pantun> get _historyItems {
    return HistoryStore.history;
  }

  List<Pantun> get _savedItems {
    return AppStore.collection
        .where((Pantun pantun) => pantun.saved)
        .toList();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _copyPantun(Pantun item) async {
    try {
      await Clipboard.setData(
        ClipboardData(text: item.text),
      );

      _showMessage('Pantun telah disalin.');
    } catch (error) {
      debugPrint('COPY COLLECTION ERROR: $error');
      _showMessage('Pantun tidak dapat disalin.');
    }
  }

  Future<void> _sharePantun(Pantun item) async {
    final StringBuffer message = StringBuffer();

    message.writeln('✨ Pantun Istimewa ✨');
    message.writeln();
    message.writeln(item.text);
    message.writeln();
    message.writeln('Tema: ${item.theme}');
    message.writeln('Mood: ${item.mood}');

    if (item.location.trim().isNotEmpty) {
      message.writeln(
        'Lokasi / Majlis: ${item.location}',
      );
    }

    message.writeln();
    message.write(
      'Dikongsi melalui aplikasi PantunFlow.',
    );

    try {
      await Share.share(
        message.toString(),
        subject: 'Pantun daripada PantunFlow',
      );
    } catch (error) {
      debugPrint('SHARE COLLECTION ERROR: $error');
      _showMessage('Pantun tidak dapat dikongsi.');
    }
  }

  Future<void> _editPantun(Pantun item) async {
    String editedText = item.text;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Edit Pantun',
            style: TextStyle(
              color: deepMaroon,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextFormField(
            initialValue: item.text,
            minLines: 4,
            maxLines: 8,
            textCapitalization:
            TextCapitalization.sentences,
            onChanged: (String value) {
              editedText = value;
            },
            decoration: InputDecoration(
              hintText: 'Masukkan teks pantun',
              filled: true,
              fillColor: paper,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: maroon,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editedText.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Teks pantun tidak boleh kosong.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: cream,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) return;

    final int index = AppStore.collection.indexWhere(
          (Pantun pantun) => pantun.id == item.id,
    );

    if (index == -1) {
      _showMessage('Pantun tidak dijumpai.');
      return;
    }

    final Pantun updatedPantun = item.copyWith(
      text: editedText.trim(),
    );

    AppStore.collection[index] = updatedPantun;

    try {
      await AppStore.updatePantunInFirebase(
        updatedPantun,
      );

      AppStore.notifyCollectionChanged();

      _showMessage(
        'Pantun berjaya dikemas kini.',
      );
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'Gagal mengemas kini pantun.',
      );
    }
  }

  Future<void> _removeFromSaved(Pantun item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Buang Daripada Simpanan?',
            style: TextStyle(
              color: deepMaroon,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Pantun ini akan dibuang daripada Koleksi Saya, tetapi tidak dipadam daripada data utama aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: cream,
              ),
              child: const Text('Buang'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final int index = AppStore.collection.indexWhere(
          (Pantun pantun) => pantun.id == item.id,
    );

    if (index == -1) return;

    try {
      await AppStore.removePantunFromFirebase(
        item,
      );

      AppStore.collection[index].saved = false;

      AppStore.removeInteraction(item);

      AppStore.notifyCollectionChanged();

      _showMessage(
        'Pantun dibuang daripada simpanan.',
      );
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);

      _showMessage(
        'Gagal membuang pantun.',
      );
    }
  }

  Widget _buildHistoryEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: maroon.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: maroon,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Sejarah Penjanaan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepMaroon,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantun yang berjaya dijana akan dipaparkan secara automatik di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D6D61),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: maroon.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: maroon,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Pantun Disimpan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepMaroon,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantun yang anda simpan akan dipaparkan di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D6D61),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantunCard(Pantun item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2D3B8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollectionThumbnail(theme: item.theme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTag(
                      icon: Icons.category_outlined,
                      label: item.theme,
                    ),
                    _buildTag(
                      icon:
                      Icons.sentiment_satisfied_alt_rounded,
                      label: item.mood,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepMaroon,
                    height: 1.45,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSmallAction(
                      icon: Icons.copy_outlined,
                      tooltip: 'Salin',
                      onTap: () => _copyPantun(item),
                    ),
                    _buildSmallAction(
                      icon: Icons.share_outlined,
                      tooltip: 'Kongsi',
                      onTap: () => _sharePantun(item),
                    ),
                    _buildSmallAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit',
                      onTap: () => _editPantun(item),
                    ),
                    const Spacer(),
                    _buildSmallAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Buang',
                      color: maroon,
                      onTap: () =>
                          _removeFromSaved(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Pantun item) {
    final bool alreadySaved = AppStore.collection.any(
      (Pantun pantun) => pantun.id == item.id && pantun.saved,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2D3B8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollectionThumbnail(
            theme: item.theme,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildTag(
                      icon: Icons.category_outlined,
                      label: item.theme,
                    ),
                    _buildTag(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      label: item.mood,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.generatedAt != null
                      ? "Dijana • ${DateFormat('dd MMM yyyy, HH:mm').format(item.generatedAt!)}"
                      : "Dijana • Baru sahaja",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: deepMaroon,
                    height: 1.45,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSmallAction(
                      icon: Icons.visibility_outlined,
                      tooltip: 'Lihat',
                      onTap: () => _viewHistoryPantun(item),
                    ),
                    _buildSmallAction(
                      icon: Icons.copy_outlined,
                      tooltip: 'Salin',
                      onTap: () => _copyPantun(item),
                    ),
                    _buildSmallAction(
                      icon: Icons.share_outlined,
                      tooltip: 'Kongsi',
                      onTap: () => _sharePantun(item),
                    ),
                    _buildSmallAction(
                      icon: alreadySaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      tooltip: alreadySaved ? 'Sudah Disimpan' : 'Simpan',
                      color: alreadySaved ? Colors.red : maroon,
                      onTap: alreadySaved
                          ? () {
                              _showMessage(
                                'Pantun ini sudah disimpan.',
                              );
                            }
                          : () {
                              _saveHistoryPantun(item);
                            },
                    ),
                    const Spacer(),
                    _buildSmallAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Padam Sejarah',
                      color: maroon,
                      onTap: () =>
                          _deleteHistoryPantun(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewHistoryPantun(Pantun item) async {
    final String formattedDate = item.generatedAt != null
        ? DateFormat('dd/MM/yyyy, HH:mm').format(item.generatedAt!)
        : 'Tiada';

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: maroon,
              ),
              SizedBox(width: 8),
              Text(
                'Sejarah Pantun',
                style: TextStyle(
                  color: deepMaroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  item.text,
                  style: const TextStyle(
                    color: deepMaroon,
                    fontSize: 16,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MAKLUMAT PENJANAAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  label: 'Kata Kunci',
                  value: item.keyword.isNotEmpty ? item.keyword : 'Tiada',
                ),
                _buildInfoRow(
                  label: 'Masa Dijana',
                  value: formattedDate,
                ),
                _buildInfoRow(
                  label: 'Status',
                  value: AppStore.collection.any(
                    (Pantun p) => p.id == item.id && p.saved,
                  ) ? 'Disimpan' : 'Auto Saved',
                ),
                const SizedBox(height: 16),
                const Text(
                  'KLASIFIKASI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTag(
                  icon: Icons.category_outlined,
                  label: item.theme,
                ),
                const SizedBox(height: 8),
                _buildTag(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  label: item.mood,
                ),
                if (item.location.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildTag(
                    icon: Icons.location_on_outlined,
                    label: item.location,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: deepMaroon,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveHistoryPantun(Pantun item) async {
    final int existingIndex = AppStore.collection.indexWhere(
      (Pantun pantun) => pantun.id == item.id,
    );

    if (existingIndex >= 0 && AppStore.collection[existingIndex].saved) {
      _showMessage(
        'Pantun ini sudah berada dalam simpanan.',
      );
      return;
    }

    final Pantun savedPantun = item.copyWith(
      saved: true,
    );

    try {
      if (existingIndex >= 0) {
        AppStore.collection[existingIndex] = savedPantun;
      } else {
        AppStore.collection.insert(
          0,
          savedPantun,
        );
      }

      AppStore.recordInteraction(savedPantun);

      await AppStore.savePantunToFirebase(
        savedPantun,
      );

      AppStore.notifyCollectionChanged();

      _showMessage(
        'Pantun berjaya disimpan.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SAVE HISTORY PANTUN ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (existingIndex >= 0) {
        AppStore.collection[existingIndex].saved = false;
      } else {
        AppStore.collection.removeWhere(
          (Pantun pantun) => pantun.id == savedPantun.id,
        );
      }

      AppStore.rebuildInteractionScores();
      AppStore.notifyCollectionChanged();

      _showMessage(
        'Pantun gagal disimpan.',
      );
    }
  }

  Future<void> _deleteHistoryPantun(
    Pantun item,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Padam Daripada Sejarah?',
            style: TextStyle(
              color: deepMaroon,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Pantun ini akan dipadam daripada sejarah penjanaan. Pantun yang telah disimpan tidak akan terjejas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: cream,
              ),
              child: const Text('Padam'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await HistoryStore.deleteHistory(item);

      _showMessage(
        'Pantun dipadam daripada sejarah.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'DELETE HISTORY ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showMessage(
        'Pantun gagal dipadam.',
      );
    }
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: maroon.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: maroon,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: maroon,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = deepMaroon,
  }) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(
        icon,
        color: color,
        size: 21,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppStore.collectionNotifier,
      builder: (BuildContext context, int collectionValue, Widget? child) {
        return ValueListenableBuilder<int>(
          valueListenable: HistoryStore.historyNotifier,
          builder: (BuildContext context, int historyValue, Widget? child) {
            final List<Pantun> items = _selectedTab == 0 ? _savedItems : _historyItems;

            return BatikBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    const PageHeader(
                      title: 'Koleksi Saya',
                      subtitle: 'Pantun kegemaran anda',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        18,
                        20,
                        10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 0 ? maroon : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "❤️ Disimpan",
                                        style: TextStyle(
                                          color: _selectedTab == 0 ? Colors.white : deepMaroon,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedTab == 1 ? maroon : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "🕘 Sejarah",
                                        style: TextStyle(
                                          color: _selectedTab == 1 ? Colors.white : deepMaroon,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                _selectedTab == 0 ? "Disimpan" : "Sejarah",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 19,
                                  color: deepMaroon,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: maroon.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${items.length} pantun",
                                  style: const TextStyle(
                                    color: maroon,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? (_selectedTab == 0 ? _buildEmptyState() : _buildHistoryEmptyState())
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                8,
                                20,
                                24,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) {
                                return const SizedBox(
                                  height: 13,
                                );
                              },
                              itemBuilder: (_, int index) {
                                final Pantun item = items[index];

                                if (_selectedTab == 0) {
                                  return _buildPantunCard(item);
                                }

                                return _buildHistoryCard(item);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}