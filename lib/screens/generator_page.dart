import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/pantun_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'result_page.dart';

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

  String get _chosenMood => mood < .34 ? 'Gembira' : mood < .67 ? 'Tenang' : 'Sayu';

  void _generatePantun() {
    final pantun = generatePantun(keywordCtrl.text, selectedTheme, _chosenMood, useLocation ? locationCtrl.text : '');
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ResultPage(pantun: pantun)));
  }

  @override
  Widget build(BuildContext context) => BatikBackground(
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Penjana Pantun AI', subtitle: 'Cipta pantun yang terasa peribadi'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Cerita atau kata kunci'),
                      const SizedBox(height: 8),
                      TextField(maxLines: 4, controller: keywordCtrl, decoration: appInput('Contoh: rindu pada sahabat lama...')),
                      const SizedBox(height: 22),
                      const FieldLabel('Mood pantun'),
                      Slider(value: mood, min: 0, max: 1, divisions: 4, activeColor: maroon, inactiveColor: const Color(0xFFD8C5A5), onChanged: (value) => setState(() => mood = value)),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Gembira', style: TextStyle(color: deepMaroon)), Text('Tenang', style: TextStyle(color: deepMaroon)), Text('Sayu', style: TextStyle(color: deepMaroon))]),
                      const SizedBox(height: 22),
                      const FieldLabel('Tema'),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          side: WidgetStateProperty.all(const BorderSide(color: maroon)),
                          foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? cream : maroon),
                          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? maroon : paper),
                        ),
                        segments: const [ButtonSegment(value: 'Cinta', label: Text('Cinta')), ButtonSegment(value: 'Nasihat', label: Text('Nasihat')), ButtonSegment(value: 'Persahabatan', label: Text('Sahabat'))],
                        selected: {selectedTheme},
                        onSelectionChanged: (value) => setState(() => selectedTheme = value.first),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: paper, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2D3B8))),
                        child: Row(
                          children: [
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Gunakan lokasi / majlis', style: TextStyle(fontWeight: FontWeight.bold, color: deepMaroon)), SizedBox(height: 2), Text('Jadikan pantun lebih bermakna', style: TextStyle(fontSize: 12))])),
                            CupertinoSwitch(value: useLocation, activeTrackColor: maroon, onChanged: (value) => setState(() => useLocation = value)),
                          ],
                        ),
                      ),
                      if (useLocation) ...[
                        const SizedBox(height: 12),
                        TextField(controller: locationCtrl, decoration: appInput('Contoh: Johor Bahru / Hari Ibu')),
                      ],
                      const SizedBox(height: 28),
                      AppButton(label: 'JANA PANTUN', icon: Icons.auto_awesome, onPressed: _generatePantun),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
