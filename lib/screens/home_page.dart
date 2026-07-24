import 'dart:math'; // Diperlukan untuk memilih pantun secara rawak
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/pantun.dart';
import '../services/pantun_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';
import '../screens/theme_pantun_page.dart'; // Fail skrin senarai pantun mengikut tema

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Pantun? _currentRecommended;

  @override
  void initState() {
    super.initState();
    // Muat turun fail JSON dari assets terlebih dahulu, kemudian jana pantun rawak
    AppStore.loadPantunFromAsset().then((_) {
      if (mounted) {
        _generateRandomRecommendation();
      }
    });
  }

  // TAMBAHAN: Memastikan halaman dikemas kini automatik apabila pengguna tukar tema di profil dan kembali ke sini
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppStore.collection.isNotEmpty) {
      _generateRandomRecommendation();
    }
  }

  void _generateRandomRecommendation() {
    setState(() {
      final matches = AppStore.collection
          .where((pantun) => pantun.theme.toLowerCase() == AppStore.preferredTheme.toLowerCase())
          .toList();

      if (matches.isNotEmpty) {
        // Pilih satu pantun secara rawak daripada kategori kegemaran
        _currentRecommended = matches[Random().nextInt(matches.length)];
      } else if (AppStore.collection.isNotEmpty) {
        // Jika tiada padanan kategori, pilih rawak dari seluruh senarai
        _currentRecommended = AppStore.collection[Random().nextInt(AppStore.collection.length)];
      } else {
        // Fallback jika pangkalan data kosong
        _currentRecommended = Pantun(
          id: '0',
          text: 'Bunga melati di dalam taman,\nTempat bermain si anak dara;\nMari mulakan hari dengan senyuman,\nSemoga kita gembira sejahtera.',
          theme: 'Nasihat',
          mood: 'Gembira',
          location: '',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BatikBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: maroon,
          onRefresh: () async {
            _generateRandomRecommendation();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24, 
                      backgroundColor: maroon, 
                      child: Icon(Icons.person, color: cream),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Pagi,\n${AppStore.name}', 
                            style: const TextStyle(
                              fontWeight: FontWeight.w800, 
                              fontSize: 19, 
                              height: 1.25, 
                              color: deepMaroon,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // BADGE DIBAWAH: Memaparkan status muatan data secara real-time!
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: maroon.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Pangkalan Data: ${AppStore.collection.length} Pantun Warisan',
                              style: const TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: maroon,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.notifications_none_rounded, color: deepMaroon),
                  ],
                ),
                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pantun Pilihan Hari Ini', 
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: deepMaroon),
                    ),
                    // BUTANG REFRESH: Membolehkan pengguna menukar pantun serta-merta
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: maroon),
                      tooltip: 'Tukar Pantun Rawak',
                      onPressed: _generateRandomRecommendation,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_currentRecommended != null)
                  FeaturedPantun(pantun: _currentRecommended!)
                else
                  const Center(child: CircularProgressIndicator(color: maroon)),
                
                const SizedBox(height: 22),
                const Text(
                  'Pilih Tema', 
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: deepMaroon),
                ),
                const SizedBox(height: 8),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 11,
                  childAspectRatio: 1.5,
                  children: const [
                    ThemeTile(
                      title: 'Peribahasa & Kiasan', 
                      icon: Icons.auto_stories_outlined, 
                      shade: Color(0xFF5A1E2B), // Tona maroon gelap
                    ),
                    ThemeTile(
                      title: 'Agama & Spiritual', 
                      icon: Icons.mosque_outlined, 
                      shade: Color(0xFF3B2219), // Tona coklat tua
                    ),
                    ThemeTile(
                      title: 'Budi & Adab', 
                      icon: Icons.handshake_outlined, 
                      shade: Color(0xFF965B32), // Tona coklat tanah
                    ),
                    ThemeTile(
                      title: 'Cinta & Kasih Sayang', 
                      icon: Icons.favorite_outline, 
                      shade: Color(0xFF6B313F), // Tona maroon keunguan
                    ),
                    ThemeTile(
                      title: 'Nasihat & Moral', 
                      icon: Icons.menu_book_outlined, 
                      shade: Color(0xFF5A1E2B), // Kitar semula tona maroon gelap
                    ),
                    ThemeTile(
                      title: 'Jenaka', 
                      icon: Icons.sentiment_very_satisfied_outlined, 
                      shade: Color(0xFF965B32), // Kitar semula tona coklat tanah
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Kotak Tema dengan Tona Warna Eksklusif dan Fungsi Klik Aktif
class ThemeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color shade;

  const ThemeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.shade,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThemePantunPage(themeName: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: shade,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const Spacer(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}