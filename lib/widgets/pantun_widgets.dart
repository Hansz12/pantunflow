import 'package:flutter/material.dart';

import '../models/pantun.dart';
import '../theme/app_theme.dart';

class ThemeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color shade;
  const ThemeTile({super.key, required this.title, required this.icon, required this.shade});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: shade,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x25000000), blurRadius: 7, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cream),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: cream, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class FeaturedPantun extends StatelessWidget {
  final Pantun pantun;

  const FeaturedPantun({
    super.key,
    required this.pantun,
  });

  String _getBackgroundAsset(String theme) {
    final normalized = theme.toLowerCase();

    if (normalized.contains('cinta')) {
      return 'assets/images/pantun_cinta.jpg';
    }

    if (normalized.contains('agama')) {
      return 'assets/images/pantun_agama.jpg';
    }

    if (normalized.contains('jenaka')) {
      return 'assets/images/pantun_jenaka.jpg';
    }

    if (normalized.contains('budi')) {
      return 'assets/images/pantun_budi.jpg';
    }

    if (normalized.contains('peribahasa') ||
        normalized.contains('kiasan')) {
      return 'assets/images/pantun_peribahasa.jpg';
    }

    return 'assets/images/pantun_nasihat.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        _getBackgroundAsset(pantun.theme);

    final bool hasLocation =
        pantun.location.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Container(
                  color: deepMaroon,
                );
              },
            ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x99000000),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pantun Pilihan Hari Ini',
                    style: TextStyle(
                      color: cream,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        pantun.text,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: cream,
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.34),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            pantun.theme,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: cream,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      if (hasLocation) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: cream,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  pantun.location,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: cream,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;
  const ResultAction({super.key, required this.icon, required this.label, required this.onTap, this.highlighted = false});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: highlighted ? maroon : paper,
                shape: BoxShape.circle,
                border: Border.all(color: maroon.withAlpha(64)),
              ),
              child: Icon(icon, color: highlighted ? cream : maroon),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: deepMaroon)),
          ],
        ),
      );
}

class CollectionThumbnail extends StatelessWidget {
  final String theme;
  const CollectionThumbnail({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final icon = theme == 'Cinta' ? Icons.favorite : theme == 'Nasihat' ? Icons.menu_book : Icons.auto_awesome;
    return Container(
      width: 70,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [maroon, deepMaroon], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 8, child: Icon(Icons.auto_awesome, color: Color(0x55F8F1DF), size: 24)),
          Icon(icon, color: cream, size: 30),
        ],
      ),
    );
  }
}
