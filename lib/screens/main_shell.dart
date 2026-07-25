import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'collection_page.dart';
import 'generator_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomePage(),
      GeneratorPage(),
      CollectionPage(),
      ProfilePage(),
    ];
  }

  void _changePage(int newIndex) {
    if (_currentIndex == newIndex) {
      return;
    }

    setState(() {
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 68,
            backgroundColor: deepMaroon,
            indicatorColor: maroon,
            selectedIndex: _currentIndex,
            onDestinationSelected: _changePage,
            labelTextStyle:
            WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states) {
                final bool isSelected =
                states.contains(WidgetState.selected);

                return TextStyle(
                  color: cream,
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                );
              },
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: cream,
                ),
                selectedIcon: Icon(
                  Icons.home,
                  color: cream,
                ),
                label: 'Utama',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  color: cream,
                ),
                selectedIcon: Icon(
                  Icons.auto_awesome,
                  color: cream,
                ),
                label: 'Jana',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bookmark_outline,
                  color: cream,
                ),
                selectedIcon: Icon(
                  Icons.bookmark,
                  color: cream,
                ),
                label: 'Koleksi',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: cream,
                ),
                selectedIcon: Icon(
                  Icons.person,
                  color: cream,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}