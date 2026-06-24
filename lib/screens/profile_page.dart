import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BatikBackground(
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Profil', subtitle: 'Akaun PantunFlow anda'),
              const SizedBox(height: 30),
              const CircleAvatar(radius: 45, backgroundColor: maroon, child: Icon(Icons.person, size: 48, color: cream)),
              const SizedBox(height: 12),
              Text(AppStore.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 23, color: deepMaroon)),
              const Text('Pencinta pantun', style: TextStyle(color: maroon)),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileInfo(icon: Icons.favorite_outline, title: 'Tema Kegemaran', value: AppStore.preferredTheme),
                    const SizedBox(height: 12),
                    ProfileInfo(icon: Icons.bookmark_outline, title: 'Jumlah Pantun Disimpan', value: '${AppStore.collection.length} pantun'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
