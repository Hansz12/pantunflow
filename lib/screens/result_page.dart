import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_store.dart';
import '../models/pantun.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';

class ResultPage extends StatefulWidget {
  final Pantun pantun;

  const ResultPage({
    super.key,
    required this.pantun,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSharing = false;
  bool _isCopying = false;

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

  bool _isPantunInCollection(Pantun target) {
    return AppStore.collection.any(
          (Pantun pantun) => pantun.id == target.id,
    );
  }

  void _toggleSaved() {
    final bool newSavedStatus = !widget.pantun.saved;

    setState(() {
      widget.pantun.saved = newSavedStatus;
    });

    /*
      AppStore.collection digunakan sebagai pangkalan data utama pantun.

      Jangan remove pantun daripada collection apabila pengguna
      membuang daripada simpanan kerana ia boleh menghapuskan pantun
      daripada data utama aplikasi.
    */

    if (newSavedStatus && !_isPantunInCollection(widget.pantun)) {
      AppStore.collection.insert(0, widget.pantun);
    }

    _showMessage(
      newSavedStatus
          ? 'Pantun berjaya disimpan dalam koleksi.'
          : 'Pantun telah dibuang daripada simpanan.',
    );
  }

  Future<void> _copyPantun() async {
    if (_isCopying) return;

    setState(() {
      _isCopying = true;
    });

    try {
      await Clipboard.setData(
        ClipboardData(
          text: widget.pantun.text,
        ),
      );

      if (!mounted) return;

      _showMessage(
        'Pantun telah disalin ke papan klip.',
      );
    } catch (error, stackTrace) {
      debugPrint('COPY PANTUN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        'Pantun tidak dapat disalin. Sila cuba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCopying = false;
        });
      }
    }
  }

  String _buildShareMessage() {
    final StringBuffer message = StringBuffer();

    message.writeln('✨ Pantun Istimewa ✨');
    message.writeln();
    message.writeln(widget.pantun.text);
    message.writeln();
    message.writeln(
      'Tema: ${widget.pantun.theme}',
    );
    message.writeln(
      'Mood: ${widget.pantun.mood}',
    );

    if (widget.pantun.location.trim().isNotEmpty) {
      message.writeln(
        'Lokasi / Majlis: ${widget.pantun.location}',
      );
    }

    message.writeln();
    message.write(
      'Dihasilkan melalui aplikasi PantunFlow.',
    );

    return message.toString();
  }

  Future<void> _sharePantun() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await Share.share(
        _buildShareMessage(),
        subject: 'Pantun daripada PantunFlow',
      );
    } catch (error, stackTrace) {
      debugPrint('SHARE PANTUN ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        'Pantun tidak dapat dikongsi. Sila cuba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _generateAgain() {
    Navigator.of(context).pop();
  }

  Widget _buildPantunCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        25,
        22,
        22,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withOpacity(0.25),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: gold,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          SelectableText(
            widget.pantun.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              height: 1.75,
              color: deepMaroon,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 22),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInformationBadge(
                icon: Icons.category_outlined,
                label: widget.pantun.theme,
              ),
              _buildInformationBadge(
                icon: Icons.sentiment_satisfied_alt_rounded,
                label: widget.pantun.mood,
              ),
              if (widget.pantun.location.trim().isNotEmpty)
                _buildInformationBadge(
                  icon: Icons.location_on_outlined,
                  label: widget.pantun.location,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: maroon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: maroon.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: maroon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: maroon,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: paper.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2D3B8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ResultAction(
            icon: _isCopying
                ? Icons.hourglass_top_rounded
                : Icons.copy_outlined,
            label: _isCopying ? 'Menyalin' : 'Salin',
            onTap: _copyPantun,
          ),
          ResultAction(
            icon: widget.pantun.saved
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            label: widget.pantun.saved
                ? 'Disimpan'
                : 'Simpan',
            highlighted: widget.pantun.saved,
            onTap: _toggleSaved,
          ),
          ResultAction(
            icon: _isSharing
                ? Icons.hourglass_top_rounded
                : Icons.share_outlined,
            label: _isSharing ? 'Membuka' : 'Kongsi',
            onTap: _sharePantun,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BatikBackground(
        child: SafeArea(
          child: Column(
            children: [
              PageHeader(
                title: 'Keputusan Penjanaan',
                subtitle: 'Pantun istimewa untuk anda',
                leading: IconButton(
                  tooltip: 'Kembali',
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: cream,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: maroon.withOpacity(0.09),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: maroon,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'HASIL PANTUN',
                              style: TextStyle(
                                letterSpacing: 1.3,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: maroon,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildPantunCard(),

                      const SizedBox(height: 22),

                      _buildActionSection(),

                      const SizedBox(height: 25),

                      OutlinedButton.icon(
                        onPressed: _generateAgain,
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'JANA SEMULA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: maroon,
                          side: const BorderSide(
                            color: maroon,
                          ),
                          minimumSize:
                          const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Tekan “Jana Semula” untuk kembali dan mengubah kata kunci, mood atau tema.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF7D6D61),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}