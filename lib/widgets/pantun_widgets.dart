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
  const FeaturedPantun({super.key, required this.pantun});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: deepMaroon,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(20)),
              child: Text(pantun.theme.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: deepMaroon)),
            ),
            const SizedBox(height: 12),
            Text(pantun.text, style: const TextStyle(color: cream, height: 1.5, fontSize: 15)),
          ],
        ),
      );
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
