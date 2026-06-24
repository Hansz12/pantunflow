import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PantunFlowApp());

const maroon = Color(0xFF641225);
const deepMaroon = Color(0xFF3B1C0E);
const cream = Color(0xFFF8F1DF);
const paper = Color(0xFFFFFBEF);
const gold = Color(0xFFD9AD63);

class PantunFlowApp extends StatelessWidget {
  const PantunFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantunFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'serif',
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: maroon,
          primary: maroon,
          secondary: gold,
          surface: paper,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class Pantun {
  String text;
  final String theme;
  final String mood;
  final String location;
  bool saved;

  Pantun({
    required this.text,
    required this.theme,
    required this.mood,
    required this.location,
    this.saved = false,
  });
}

class AppStore {
  static String name = 'Farhana';
  static String preferredTheme = 'Cinta';
  static final List<Pantun> collection = [
    Pantun(
      text: 'Pulau Redang pasirnya putih,\nTempat berehat di hujung minggu;\nWalau badai datang menyisih,\nKasih abadi tetap ku tunggu.',
      theme: 'Cinta',
      mood: 'Gembira',
      location: 'Pulau Redang',
      saved: true,
    ),
    Pantun(
      text: 'Pagi cerah burung bernyanyi,\nAwan lembut indah berseri;\nBudi yang baik kekal dihargai,\nMenjadi cahaya dalam diri.',
      theme: 'Nasihat',
      mood: 'Tenang',
      location: '',
      saved: true,
    ),
  ];
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BatikBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                PantunMark(size: 106),
                SizedBox(height: 18),
                Text('PantunFlow', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: maroon)),
                SizedBox(height: 7),
                Text('Context-Aware AI Pantun', style: TextStyle(color: deepMaroon, letterSpacing: .5)),
              ],
            ),
          ),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  void _login() {
    AppStore.name = nameCtrl.text.trim().isEmpty ? 'Farhana' : nameCtrl.text.trim();
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BatikBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                  decoration: BoxDecoration(
                    color: paper,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [BoxShadow(color: Color(0x3D3B1C0E), blurRadius: 18, offset: Offset(0, 9))],
                  ),
                  child: Column(
                    children: [
                      const PantunMark(size: 62),
                      const SizedBox(height: 14),
                      const Text('Selamat Datang ke\nPantunFlow', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, height: 1.2, fontWeight: FontWeight.w800, color: deepMaroon)),
                      const SizedBox(height: 26),
                      TextField(controller: nameCtrl, keyboardType: TextInputType.emailAddress, decoration: appInput('Email')),
                      const SizedBox(height: 13),
                      TextField(obscureText: true, decoration: appInput('Password', suffix: Icons.visibility_off_outlined)),
                      const SizedBox(height: 20),
                      mainButton('LOG MASUK', _login),
                      const SizedBox(height: 11),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran akan dibuka tidak lama lagi.'))),
                        child: const Text('Belum ada akaun? Daftar', style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const GeneratorPage(), const CollectionPage(), const ProfilePage()];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 68,
            backgroundColor: deepMaroon,
            indicatorColor: maroon,
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(color: cream, fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal)),
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined, color: cream), selectedIcon: Icon(Icons.home, color: cream), label: 'Utama'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined, color: cream), selectedIcon: Icon(Icons.auto_awesome, color: cream), label: 'Jana'),
              NavigationDestination(icon: Icon(Icons.bookmark_outline, color: cream), selectedIcon: Icon(Icons.bookmark, color: cream), label: 'Koleksi'),
              NavigationDestination(icon: Icon(Icons.person_outline, color: cream), selectedIcon: Icon(Icons.person, color: cream), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final recommended = recommendPantun();
    return BatikBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const CircleAvatar(radius: 24, backgroundColor: maroon, child: Icon(Icons.person, color: cream)),
              const SizedBox(width: 12),
              Expanded(child: Text('Selamat Pagi,\n${AppStore.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, height: 1.25, color: deepMaroon))),
              const Icon(Icons.notifications_none_rounded, color: deepMaroon),
            ]),
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
          ]),
        ),
      ),
    );
  }
}

class ThemeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color shade;
  const ThemeTile({super.key, required this.title, required this.icon, required this.shade});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: shade, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x25000000), blurRadius: 7, offset: Offset(0, 4))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: cream), const SizedBox(width: 8), Text(title, style: const TextStyle(color: cream, fontSize: 16, fontWeight: FontWeight.bold))]),
      );
}

class FeaturedPantun extends StatelessWidget {
  final Pantun pantun;
  const FeaturedPantun({super.key, required this.pantun});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: deepMaroon, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(20)), child: Text(pantun.theme.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: deepMaroon))),
          const SizedBox(height: 12),
          Text(pantun.text, style: const TextStyle(color: cream, height: 1.5, fontSize: 15)),
        ]),
      );
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final keywordCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  double mood = .2;
  String selectedTheme = 'Cinta';
  bool useLocation = false;

  @override
  void dispose() {
    keywordCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BatikBackground(
        child: SafeArea(
          child: Column(children: [
            pageHeader('Penjana Pantun AI', 'Cipta pantun yang terasa peribadi'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const FieldLabel('Cerita atau kata kunci'),
                  const SizedBox(height: 8),
                  TextField(maxLines: 4, controller: keywordCtrl, decoration: appInput('Contoh: rindu pada sahabat lama...')),
                  const SizedBox(height: 22),
                  const FieldLabel('Mood pantun'),
                  Slider(value: mood, min: 0, max: 1, divisions: 4, activeColor: maroon, inactiveColor: const Color(0xFFD8C5A5), onChanged: (value) => setState(() => mood = value)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Gembira', style: TextStyle(color: deepMaroon)), Text('Tenang', style: TextStyle(color: deepMaroon)), Text('Sayu', style: TextStyle(color: deepMaroon))]),
                  const SizedBox(height: 22),
                  const FieldLabel('Tema'),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    style: ButtonStyle(visualDensity: VisualDensity.compact, side: WidgetStateProperty.all(const BorderSide(color: maroon)), foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? cream : maroon), backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? maroon : paper)),
                    segments: const [ButtonSegment(value: 'Cinta', label: Text('Cinta')), ButtonSegment(value: 'Nasihat', label: Text('Nasihat')), ButtonSegment(value: 'Persahabatan', label: Text('Sahabat'))],
                    selected: {selectedTheme},
                    onSelectionChanged: (value) => setState(() => selectedTheme = value.first),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2D3B8))),
                    child: Row(children: [
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Gunakan lokasi / majlis', style: TextStyle(fontWeight: FontWeight.bold, color: deepMaroon)), SizedBox(height: 2), Text('Jadikan pantun lebih bermakna', style: TextStyle(fontSize: 12))])),
                      CupertinoSwitch(value: useLocation, activeTrackColor: maroon, onChanged: (value) => setState(() => useLocation = value)),
                    ]),
                  ),
                  if (useLocation) ...[
                    const SizedBox(height: 12),
                    TextField(controller: locationCtrl, decoration: appInput('Contoh: Johor Bahru / Hari Ibu')),
                  ],
                  const SizedBox(height: 28),
                  mainButton('JANA PANTUN', () {
                    final pantun = generatePantun(keywordCtrl.text, selectedTheme, chosenMood(), useLocation ? locationCtrl.text : '');
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ResultPage(pantun: pantun)));
                  }, icon: Icons.auto_awesome),
                ]),
              ),
            ),
          ]),
        ),
      );

  String chosenMood() => mood < .34 ? 'Gembira' : mood < .67 ? 'Tenang' : 'Sayu';
}

class ResultPage extends StatefulWidget {
  final Pantun pantun;
  const ResultPage({super.key, required this.pantun});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  void _save() {
    setState(() => widget.pantun.saved = !widget.pantun.saved);
    if (widget.pantun.saved && !AppStore.collection.contains(widget.pantun)) AppStore.collection.insert(0, widget.pantun);
    if (!widget.pantun.saved) AppStore.collection.remove(widget.pantun);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: BatikBackground(
          child: SafeArea(
            child: Column(children: [
              pageHeader('Keputusan Penjanaan', 'Pantun istimewa untuk anda', leading: IconButton(icon: const Icon(Icons.arrow_back, color: cream), onPressed: () => Navigator.pop(context))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    const Text('HASIL TERBAIK', style: TextStyle(letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.bold, color: maroon)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(21, 25, 21, 21),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 11, offset: Offset(0, 5))]),
                      child: Column(children: [
                        const Icon(Icons.format_quote_rounded, color: gold, size: 34),
                        Text(widget.pantun.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.7, color: deepMaroon)),
                        const SizedBox(height: 17),
                        Text('${widget.pantun.theme}  •  ${widget.pantun.mood}', style: const TextStyle(color: maroon, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    const SizedBox(height: 21),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      ResultAction(icon: Icons.copy_outlined, label: 'Salin', onTap: () async { await Clipboard.setData(ClipboardData(text: widget.pantun.text)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pantun telah disalin.'))); }),
                      ResultAction(icon: widget.pantun.saved ? Icons.favorite : Icons.favorite_outline, label: widget.pantun.saved ? 'Disimpan' : 'Simpan', highlighted: widget.pantun.saved, onTap: _save),
                      ResultAction(icon: Icons.share_outlined, label: 'Kongsi', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ciri kongsi akan disambungkan ke platform pilihan anda.')))),
                    ]),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.refresh), label: const Text('JANA SEMULA'), style: OutlinedButton.styleFrom(foregroundColor: maroon, side: const BorderSide(color: maroon), minimumSize: const Size(double.infinity, 50))),
                  ]),
                ),
              ),
            ]),
          ),
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
        child: Column(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: highlighted ? maroon : paper, shape: BoxShape.circle, border: Border.all(color: maroon.withAlpha(64))), child: Icon(icon, color: highlighted ? cream : maroon)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: deepMaroon)),
        ]),
      );
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  Future<void> _editPantun(Pantun item) async {
    final controller = TextEditingController(text: item.text);
    await showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Edit pantun'), content: TextField(controller: controller, maxLines: 6), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), TextButton(onPressed: () { if (controller.text.trim().isNotEmpty) setState(() => item.text = controller.text.trim()); Navigator.pop(context); }, child: const Text('Simpan'))]));
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = AppStore.collection;
    return BatikBackground(
      child: SafeArea(
        child: Column(children: [
          pageHeader('Koleksi Saya', 'Pantun kegemaran anda'),
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
                        child: Row(children: [
                          CollectionThumbnail(theme: item.theme),
                          const SizedBox(width: 11),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.theme, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: maroon)), const SizedBox(height: 3), Text(item.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: deepMaroon, height: 1.35))])),
                          Column(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Suka', icon: Icon(item.saved ? Icons.favorite : Icons.favorite_outline, color: maroon), onPressed: () => setState(() => item.saved = !item.saved)), IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined, color: deepMaroon), onPressed: () => _editPantun(item)), IconButton(tooltip: 'Padam', icon: const Icon(Icons.delete_outline, color: maroon), onPressed: () => setState(() => items.removeAt(index)))])
                        ]),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class CollectionThumbnail extends StatelessWidget {
  final String theme;
  const CollectionThumbnail({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final icon = theme == 'Cinta' ? Icons.favorite : theme == 'Nasihat' ? Icons.menu_book : Icons.auto_awesome;
    return Container(width: 70, height: 88, decoration: BoxDecoration(gradient: const LinearGradient(colors: [maroon, deepMaroon], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)), child: Stack(alignment: Alignment.center, children: [const Positioned(top: 8, child: Icon(Icons.auto_awesome, color: Color(0x55F8F1DF), size: 24)), Icon(icon, color: cream, size: 30)]));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BatikBackground(
        child: SafeArea(
          child: Column(children: [
            pageHeader('Profil', 'Akaun PantunFlow anda'),
            const SizedBox(height: 30),
            const CircleAvatar(radius: 45, backgroundColor: maroon, child: Icon(Icons.person, size: 48, color: cream)),
            const SizedBox(height: 12),
            Text(AppStore.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 23, color: deepMaroon)),
            const Text('Pencinta pantun', style: TextStyle(color: maroon)),
            const SizedBox(height: 28),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [profileInfo(Icons.favorite_outline, 'Tema Kegemaran', AppStore.preferredTheme), const SizedBox(height: 12), profileInfo(Icons.bookmark_outline, 'Jumlah Pantun Disimpan', '${AppStore.collection.length} pantun')])),
          ]),
        ),
      );
}

Pantun recommendPantun() {
  final matches = AppStore.collection.where((pantun) => pantun.theme == AppStore.preferredTheme).toList();
  return matches.isEmpty ? AppStore.collection.first : matches.first;
}

Pantun generatePantun(String keyword, String theme, String mood, String location) {
  final place = location.trim().isEmpty ? 'taman indah' : location.trim();
  final idea = keyword.trim().isEmpty ? 'kasih dan budi' : keyword.trim();
  final endings = {'Cinta': ['rindu', 'menunggu'], 'Nasihat': ['diri', 'berbakti'], 'Persahabatan': ['sehati', 'abadi']};
  final end = endings[theme] ?? ['berseri', 'dihargai'];
  final pembayang = ['Bunga melati harum mewangi,\nTumbuh segar di tepi kali;', 'Burung kenari terbang tinggi,\nHinggap sebentar di pohon jati;', 'Ombak beralun di tepi pantai,\nCahaya bulan jatuh ke bumi;'][Random().nextInt(3)];
  return Pantun(text: '$pembayang\n$idea menjadi pesan di hati,\nDi $place tetap ${end.last}.', theme: theme, mood: mood, location: location);
}

InputDecoration appInput(String hint, {IconData? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF927C68)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix == null ? null : Icon(suffix, color: deepMaroon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE5D7BB))),
    );

Widget mainButton(String text, VoidCallback onTap, {IconData? icon}) => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: .6)),
        style: ElevatedButton.styleFrom(backgroundColor: maroon, foregroundColor: cream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3),
      ),
    );

Widget pageHeader(String title, String subtitle, {Widget? leading}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(color: maroon, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
      child: Row(children: [
        SizedBox(width: 42, child: leading),
        Expanded(child: Column(children: [Text(title, style: const TextStyle(color: cream, fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Color(0xFFEFD9B4), fontSize: 12))])),
        const SizedBox(width: 42),
      ]),
    );

Widget profileInfo(IconData icon, String title, String value) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x17000000), blurRadius: 6, offset: Offset(0, 3))]),
      child: Row(children: [Container(width: 40, height: 40, decoration: const BoxDecoration(color: maroon, shape: BoxShape.circle), child: Icon(icon, color: cream)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, color: maroon)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon))]))]),
    );

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepMaroon));
}

class PantunMark extends StatelessWidget {
  final double size;
  const PantunMark({super.key, required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          Container(width: size * .78, height: size * .78, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold, width: 2), color: paper)),
          Icon(Icons.water_drop_rounded, size: size * .46, color: maroon),
          Positioned(top: size * .08, child: Icon(Icons.auto_awesome, size: size * .21, color: gold)),
          Positioned(bottom: size * .08, child: Container(width: size * .4, height: 3, color: deepMaroon)),
        ]),
      );
}

class BatikBackground extends StatelessWidget {
  final Widget child;
  const BatikBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Stack(children: [
        const Positioned.fill(child: ColoredBox(color: cream)),
        const Positioned(top: -45, right: -32, child: _BatikMotif(size: 155)),
        const Positioned(bottom: -56, left: -42, child: _BatikMotif(size: 170)),
        Positioned.fill(child: child),
      ]);
}

class _BatikMotif extends StatelessWidget {
  final double size;
  const _BatikMotif({required this.size});
  @override
  Widget build(BuildContext context) => Opacity(
        opacity: .11,
        child: SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: List.generate(5, (index) => Transform.rotate(angle: index * pi / 5, child: Container(width: size * .74, height: size * .74, decoration: BoxDecoration(border: Border.all(color: maroon, width: 2), borderRadius: BorderRadius.circular(28))))))),
      );
}
