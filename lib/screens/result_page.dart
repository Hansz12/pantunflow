import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../models/pantun.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';

class ResultPage extends StatefulWidget {
  final Pantun pantun;
  const ResultPage({super.key, required this.pantun});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  void _toggleSaved() {
    setState(() => widget.pantun.saved = !widget.pantun.saved);
    if (widget.pantun.saved && !AppStore.collection.contains(widget.pantun)) AppStore.collection.insert(0, widget.pantun);
    if (!widget.pantun.saved) AppStore.collection.remove(widget.pantun);
  }

  Future<void> _copyPantun() async {
    await Clipboard.setData(ClipboardData(text: widget.pantun.text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pantun telah disalin.')));
  }

  void _showShareNotice() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ciri kongsi akan disambungkan ke platform pilihan anda.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BatikBackground(
          child: SafeArea(
            child: Column(
              children: [
                PageHeader(title: 'Keputusan Penjanaan', subtitle: 'Pantun istimewa untuk anda', leading: IconButton(icon: const Icon(Icons.arrow_back, color: cream), onPressed: () => Navigator.pop(context))),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('HASIL TERBAIK', style: TextStyle(letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.bold, color: maroon)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(21, 25, 21, 21),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 11, offset: Offset(0, 5))]),
                          child: Column(
                            children: [
                              const Icon(Icons.format_quote_rounded, color: gold, size: 34),
                              Text(widget.pantun.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.7, color: deepMaroon)),
                              const SizedBox(height: 17),
                              Text('${widget.pantun.theme}  •  ${widget.pantun.mood}', style: const TextStyle(color: maroon, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 21),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ResultAction(icon: Icons.copy_outlined, label: 'Salin', onTap: _copyPantun),
                            ResultAction(icon: widget.pantun.saved ? Icons.favorite : Icons.favorite_outline, label: widget.pantun.saved ? 'Disimpan' : 'Simpan', highlighted: widget.pantun.saved, onTap: _toggleSaved),
                            ResultAction(icon: Icons.share_outlined, label: 'Kongsi', onTap: _showShareNotice),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.refresh), label: const Text('JANA SEMULA'), style: OutlinedButton.styleFrom(foregroundColor: maroon, side: const BorderSide(color: maroon), minimumSize: const Size(double.infinity, 50))),
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
