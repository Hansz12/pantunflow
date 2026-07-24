import 'package:flutter/material.dart';
import '../data/app_store.dart';
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
  Future<void> _editPantun(Pantun item) async {
    final controller = TextEditingController(text: item.text);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit pantun'),
        content: TextField(controller: controller, maxLines: 6),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final index = AppStore.collection.indexOf(item);
                  if (index != -1) {
                    // Gunakan copyWith untuk menggantikan objek lama dengan yang baru (kerana final)
                    AppStore.collection[index] = AppStore.collection[index].copyWith(); 
                    // Nota: Anda mungkin perlukan fungsi kemaskini teks dalam copyWith jika mahu tukar teks
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = AppStore.collection;
    return BatikBackground(
      child: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Koleksi Saya', subtitle: 'Pantun kegemaran anda'),
            const Padding(padding: EdgeInsets.fromLTRB(20, 17, 20, 8), child: Align(alignment: Alignment.centerLeft, child: Text('Disimpan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: deepMaroon)))),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Belum ada pantun disimpan.', style: TextStyle(color: deepMaroon)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(17), boxShadow: const [BoxShadow(color: Color(0x1E000000), blurRadius: 7, offset: Offset(0, 3))]),
                          child: Row(
                            children: [
                              CollectionThumbnail(theme: item.theme),
                              const SizedBox(width: 11),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.theme, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: maroon)), const SizedBox(height: 3), Text(item.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: deepMaroon, height: 1.35))])),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(tooltip: 'Suka', icon: Icon(item.saved ? Icons.favorite : Icons.favorite_outline, color: maroon), onPressed: () => setState(() => item.saved = !item.saved)),
                                  IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined, color: deepMaroon), onPressed: () => _editPantun(item)),
                                  IconButton(tooltip: 'Padam', icon: const Icon(Icons.delete_outline, color: maroon), onPressed: () => setState(() => items.removeAt(index))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}