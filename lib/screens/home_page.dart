import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/pantun.dart';
import '../theme/app_theme.dart';
import '../widgets/pantun_widgets.dart';
import '../widgets/shared_widgets.dart';
import 'theme_pantun_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Random _random = Random();

  final List<String> _recentPantunIds = <String>[];

  Pantun? _currentRecommended;

  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPantunData();
  }

  Future<void> _loadPantunData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await AppStore.loadPantunFromAsset();

      if (!mounted) {
        return;
      }

      if (AppStore.collection.isEmpty) {
        setState(() {
          _currentRecommended = _fallbackPantun();
          _isLoading = false;
          _loadError = null;
        });

        return;
      }

      _generateRandomRecommendation();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'HOME DATA LOAD ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError =
        'Pangkalan data pantun tidak dapat dimuatkan.';
      });
    }
  }

  String _normalizeTheme(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    if (normalized.contains('peribahasa') ||
        normalized.contains('kiasan')) {
      return 'peribahasa & kiasan';
    }

    if (normalized.contains('agama') ||
        normalized.contains('spiritual')) {
      return 'agama & spiritual';
    }

    if (normalized.contains('budi') ||
        normalized.contains('adab')) {
      return 'budi & adab';
    }

    if (normalized.contains('cinta') ||
        normalized.contains('kasih sayang')) {
      return 'cinta & kasih sayang';
    }

    if (normalized.contains('nasihat') ||
        normalized.contains('moral')) {
      return 'nasihat & moral';
    }

    if (normalized.contains('jenaka') ||
        normalized.contains('lawak')) {
      return 'jenaka';
    }

    return normalized;
  }

  void _generateRandomRecommendation() {
    if (!mounted) {
      return;
    }

    final List<Pantun> allPantun =
        AppStore.collection;

    if (allPantun.isEmpty) {
      setState(() {
        _currentRecommended = _fallbackPantun();
      });

      return;
    }

    final String preferredTheme =
    _normalizeTheme(
      AppStore.preferredTheme,
    );

    final bool hasPreferredTheme =
        preferredTheme.isNotEmpty;

    final List<Pantun> preferredMatches =
    hasPreferredTheme
        ? allPantun.where((Pantun pantun) {
      return _normalizeTheme(
        pantun.theme,
      ) ==
          preferredTheme;
    }).toList()
        : <Pantun>[];

    final List<Pantun> primarySource =
    preferredMatches.isNotEmpty
        ? preferredMatches
        : allPantun;

    List<Pantun> availablePantun =
    primarySource.where((Pantun pantun) {
      return !_recentPantunIds.contains(
        pantun.id,
      );
    }).toList();

    if (availablePantun.isEmpty) {
      _recentPantunIds.clear();

      availablePantun =
      List<Pantun>.from(primarySource);
    }

    Pantun selectedPantun = availablePantun[
    _random.nextInt(
      availablePantun.length,
    )];

    if (availablePantun.length > 1 &&
        selectedPantun.id ==
            _currentRecommended?.id) {
      final List<Pantun> alternatives =
      availablePantun.where((Pantun pantun) {
        return pantun.id !=
            _currentRecommended?.id;
      }).toList();

      if (alternatives.isNotEmpty) {
        selectedPantun = alternatives[
        _random.nextInt(
          alternatives.length,
        )];
      }
    }

    _recentPantunIds.add(
      selectedPantun.id,
    );

    if (_recentPantunIds.length > 5) {
      _recentPantunIds.removeAt(0);
    }

    setState(() {
      _currentRecommended =
          selectedPantun;
    });
  }

  Pantun _fallbackPantun() {
    return Pantun(
      id: 'fallback-home',
      text:
      'Bunga melati di dalam taman,\n'
          'Tempat bermain si anak dara;\n'
          'Mari mulakan hari dengan senyuman,\n'
          'Semoga kita gembira sejahtera.',
      theme: 'Nasihat & Moral',
      mood: 'Gembira',
      location: '',
    );
  }

  String _getGreeting() {
    final int hour =
        DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi';
    }

    if (hour >= 12 && hour < 15) {
      return 'Selamat Tengah Hari';
    }

    if (hour >= 15 && hour < 19) {
      return 'Selamat Petang';
    }

    return 'Selamat Malam';
  }

  String _formatDisplayName(
      String? fullName,
      ) {
    if (fullName == null ||
        fullName.trim().isEmpty) {
      return 'Pengguna PantunFlow';
    }

    final List<String> words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (String word) =>
      word.isNotEmpty,
    )
        .toList();

    if (words.isEmpty) {
      return 'Pengguna PantunFlow';
    }

    const Set<String> connectionWords =
    <String>{
      'bin',
      'binti',
      'a/l',
      'a/p',
      'anak',
    };

    final List<String> displayWords =
    <String>[];

    for (final String word in words) {
      if (connectionWords.contains(
        word.toLowerCase(),
      )) {
        break;
      }

      displayWords.add(word);

      if (displayWords.length == 2) {
        break;
      }
    }

    if (displayWords.isEmpty) {
      displayWords.add(words.first);
    }

    return displayWords
        .map(_toTitleCase)
        .join(' ');
  }

  String _toTitleCase(String value) {
    final String word =
    value.trim().toLowerCase();

    if (word.isEmpty) {
      return '';
    }

    return '${word[0].toUpperCase()}'
        '${word.substring(1)}';
  }

  int _getThemeCount(
      String themeName,
      ) {
    final String normalizedTheme =
    _normalizeTheme(themeName);

    return AppStore.collection
        .where((Pantun pantun) {
      return _normalizeTheme(
        pantun.theme,
      ) ==
          normalizedTheme;
    }).length;
  }

  Future<void> _refreshHome() async {
    if (AppStore.collection.isEmpty) {
      await _loadPantunData();
      return;
    }

    _generateRandomRecommendation();

    await Future<void>.delayed(
      const Duration(
        milliseconds: 350,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable:
      AppStore.nameNotifier,
      builder: (
          BuildContext context,
          String currentName,
          Widget? child,
          ) {
        final String displayName =
        _formatDisplayName(
          currentName,
        );

        return BatikBackground(
          child: SafeArea(
            child: RefreshIndicator(
              color: maroon,
              onRefresh: _refreshHome,
              child: SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      displayName,
                    ),
                    const SizedBox(height: 30),
                    _buildRecommendationHeader(),
                    const SizedBox(height: 12),
                    _buildRecommendedPantun(),
                    const SizedBox(height: 28),
                    _buildThemeHeader(),
                    const SizedBox(height: 14),
                    _buildThemeGrid(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      String displayName,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration:
          const BoxDecoration(
            color: maroon,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: cream,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},\n'
                    '$displayName',
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 20,
                  height: 1.18,
                  color: deepMaroon,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                  maroon.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  _isLoading
                      ? 'Memuatkan pangkalan data...'
                      : 'Pangkalan Data: '
                      '${AppStore.collection.length} '
                      'Pantun Warisan',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                    FontWeight.w700,
                    color: maroon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Pantun Pilihan Hari Ini',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 21,
              color: deepMaroon,
            ),
          ),
        ),
        Material(
          color: maroon.withOpacity(0.10),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: _isLoading
                ? null
                : _generateRandomRecommendation,
            tooltip: 'Tukar pantun pilihan',
            icon: const Icon(
              Icons.refresh_rounded,
              color: maroon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedPantun() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: paper.withOpacity(0.75),
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: maroon,
              ),
              SizedBox(height: 14),
              Text(
                'Memuatkan pantun...',
                style: TextStyle(
                  color: deepMaroon,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Container(
        width: double.infinity,
        padding:
        const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: paper,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color:
            maroon.withOpacity(0.20),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: maroon,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: deepMaroon,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadPantunData,
              icon: const Icon(
                Icons.refresh_rounded,
                color: maroon,
              ),
              label: const Text(
                'Cuba Lagi',
                style: TextStyle(
                  color: maroon,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentRecommended == null) {
      return const SizedBox.shrink();
    }

    return FeaturedPantun(
      pantun: _currentRecommended!,
    );
  }

  Widget _buildThemeHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Pilih Tema',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 21,
              color: deepMaroon,
            ),
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: maroon.withOpacity(0.10),
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: const Text(
            '6 Tema',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: maroon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeGrid() {
    final List<ThemeItem> themes =
    <ThemeItem>[
      ThemeItem(
        title: 'Peribahasa & Kiasan',
        icon:
        Icons.auto_stories_outlined,
        shade:
        const Color(0xFF5A1E2B),
        count: _getThemeCount(
          'Peribahasa & Kiasan',
        ),
      ),
      ThemeItem(
        title: 'Agama & Spiritual',
        icon: Icons.mosque_outlined,
        shade:
        const Color(0xFF3B2219),
        count: _getThemeCount(
          'Agama & Spiritual',
        ),
      ),
      ThemeItem(
        title: 'Budi & Adab',
        icon:
        Icons.handshake_outlined,
        shade:
        const Color(0xFF965B32),
        count: _getThemeCount(
          'Budi & Adab',
        ),
      ),
      ThemeItem(
        title:
        'Cinta & Kasih Sayang',
        icon:
        Icons.favorite_outline_rounded,
        shade:
        const Color(0xFF6B313F),
        count: _getThemeCount(
          'Cinta & Kasih Sayang',
        ),
      ),
      ThemeItem(
        title: 'Nasihat & Moral',
        icon: Icons.menu_book_outlined,
        shade:
        const Color(0xFF5A1E2B),
        count: _getThemeCount(
          'Nasihat & Moral',
        ),
      ),
      ThemeItem(
        title: 'Jenaka',
        icon: Icons
            .sentiment_very_satisfied_outlined,
        shade:
        const Color(0xFF965B32),
        count: _getThemeCount(
          'Jenaka',
        ),
      ),
    ];

    return GridView.builder(
      itemCount: themes.length,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        childAspectRatio: 1.17,
      ),
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        final ThemeItem theme =
        themes[index];

        return ThemeTile(
          title: theme.title,
          icon: theme.icon,
          shade: theme.shade,
          pantunCount: theme.count,
          isLoading: _isLoading,
        );
      },
    );
  }
}

class ThemeItem {
  final String title;
  final IconData icon;
  final Color shade;
  final int count;

  const ThemeItem({
    required this.title,
    required this.icon,
    required this.shade,
    required this.count,
  });
}

class ThemeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color shade;
  final int pantunCount;
  final bool isLoading;

  const ThemeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.shade,
    required this.pantunCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: shade,
      borderRadius:
      BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  ThemePantunPage(
                    themeName: title,
                  ),
            ),
          );
        },
        splashColor:
        Colors.white.withOpacity(0.16),
        highlightColor:
        Colors.white.withOpacity(0.06),
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              Colors.white.withOpacity(0.09),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration:
                    BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.14),
                      shape:
                      BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    color: Colors.white70,
                    size: 19,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 14,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                isLoading
                    ? 'Memuatkan...'
                    : pantunCount > 0
                    ? '$pantunCount pantun'
                    : 'Lihat koleksi',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.78),
                  fontWeight:
                  FontWeight.w600,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}