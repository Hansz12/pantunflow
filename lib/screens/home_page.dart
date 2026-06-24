import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../services/pantun_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final recommended = recommendPantun();
    return BatikBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: maroon, child: Icon(Icons.person, color: cream)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Selamat Pagi,\n${AppStore.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, height: 1.25, color: deepMaroon))),
                  const Icon(Icons.notifications_none_rounded, color: deepMaroon),
                ],
              ),
              const SizedBox(height: 26),
              const Text('Pantun Pilihan Hari Ini', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: deepMaroon)),
              const SizedBox(height: 10),
              FeaturedPantun(pantun: recommended),
              const SizedBox(height: 22),
              const Text('Pilih Tema', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: deepMaroon)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 11,
                crossAxisSpacing: 11,
                childAspectRatio: 1.5,
                children: const [
                  ThemeTile(title: 'Cinta', icon: Icons.favorite_outline, shade: maroon),
                  ThemeTile(title: 'Nasihat', icon: Icons.menu_book_outlined, shade: deepMaroon),
                  ThemeTile(title: 'Jenaka', icon: Icons.sentiment_very_satisfied_outlined, shade: Color(0xFF915B2E)),
                  ThemeTile(title: 'Majlis Rasmi', icon: Icons.account_balance_outlined, shade: Color(0xFF713B46)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
