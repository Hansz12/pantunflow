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
  final TextEditingController keywordCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  double mood = 0.2;
  String selectedTheme = 'Cinta';

  bool useLocation = false;
  bool _isLoading = false;

  String? _keywordError;
  String? _locationError;

  @override
  void dispose() {
    keywordCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  String get _chosenMood {
    if (mood < 0.34) {
      return 'Gembira';
    }

    if (mood < 0.67) {
      return 'Tenang';
    }

    return 'Sayu';
  }

  void _validateKeyword(String value) {
    if (!mounted) return;

    setState(() {
      final String keyword = value.trim();

      if (keyword.isEmpty) {
        _keywordError = 'Sila masukkan cerita atau kata kunci.';
      } else if (keyword.length < 3) {
        _keywordError =
        'Kata kunci mestilah sekurang-kurangnya 3 aksara.';
      } else {
        _keywordError = null;
      }
    });
  }

  void _validateLocation(String value) {
    if (!mounted) return;

    setState(() {
      final String location = value.trim();

      if (useLocation && location.isEmpty) {
        _locationError = 'Sila masukkan lokasi atau nama majlis.';
      } else {
        _locationError = null;
      }
    });
  }

  bool _validateForm() {
    final String keyword = keywordCtrl.text.trim();
    final String location = locationCtrl.text.trim();

    setState(() {
      if (keyword.isEmpty) {
        _keywordError = 'Sila masukkan cerita atau kata kunci.';
      } else if (keyword.length < 3) {
        _keywordError =
        'Kata kunci mestilah sekurang-kurangnya 3 aksara.';
      } else {
        _keywordError = null;
      }

      if (useLocation && location.isEmpty) {
        _locationError = 'Sila masukkan lokasi atau nama majlis.';
      } else {
        _locationError = null;
      }
    });

    return _keywordError == null && _locationError == null;
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pantun Tidak Berjaya Dijana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepMaroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 130,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePantun() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    if (!_validateForm()) {
      return;
    }

    final String keyword = keywordCtrl.text.trim();
    final String location =
    useLocation ? locationCtrl.text.trim() : '';

    setState(() {
      _isLoading = true;
    });

    try {
      final pantun = await generatePantun(
        keyword,
        selectedTheme,
        _chosenMood,
        location,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultPage(
            pantun: pantun,
          ),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('AI PANTUN GENERATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await _showErrorDialog(
        'Sistem AI tidak dapat menjana pantun sekarang. '
            'Sila periksa sambungan Internet dan cuba lagi.',
      );
    }
  }

  Widget _buildContent() {
    return BatikBackground(
      child: SafeArea(
        child: Column(
          children: [
            const PageHeader(
              title: 'Penjana Pantun AI',
              subtitle: 'Cipta pantun yang terasa peribadi',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(
                      'Cerita atau kata kunci',
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: keywordCtrl,
                      enabled: !_isLoading,
                      minLines: 4,
                      maxLines: 5,
                      maxLength: 200,
                      textCapitalization:
                      TextCapitalization.sentences,
                      textInputAction:
                      TextInputAction.newline,
                      onChanged: _validateKeyword,
                      decoration: appInput(
                        'Contoh: rindu pada sahabat lama...',
                      ).copyWith(
                        errorText: _keywordError,
                        alignLabelWithHint: true,
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: FieldLabel('Mood pantun'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: maroon.withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            _chosenMood,
                            style: const TextStyle(
                              color: maroon,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: mood,
                      min: 0,
                      max: 1,
                      divisions: 4,
                      activeColor: maroon,
                      inactiveColor:
                      const Color(0xFFD8C5A5),
                      onChanged: _isLoading
                          ? null
                          : (double value) {
                        setState(() {
                          mood = value;
                        });
                      },
                    ),

                    const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gembira',
                          style: TextStyle(
                            color: deepMaroon,
                          ),
                        ),
                        Text(
                          'Tenang',
                          style: TextStyle(
                            color: deepMaroon,
                          ),
                        ),
                        Text(
                          'Sayu',
                          style: TextStyle(
                            color: deepMaroon,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const FieldLabel('Tema'),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        style: ButtonStyle(
                          visualDensity:
                          VisualDensity.compact,
                          side: WidgetStateProperty.all(
                            const BorderSide(
                              color: maroon,
                            ),
                          ),
                          foregroundColor:
                          WidgetStateProperty.resolveWith(
                                (Set<WidgetState> states) {
                              return states.contains(
                                WidgetState.selected,
                              )
                                  ? cream
                                  : maroon;
                            },
                          ),
                          backgroundColor:
                          WidgetStateProperty.resolveWith(
                                (Set<WidgetState> states) {
                              return states.contains(
                                WidgetState.selected,
                              )
                                  ? maroon
                                  : paper;
                            },
                          ),
                        ),
                        segments: const [
                          ButtonSegment<String>(
                            value: 'Cinta',
                            icon: Icon(
                              Icons.favorite_outline_rounded,
                            ),
                            label: Text('Cinta'),
                          ),
                          ButtonSegment<String>(
                            value: 'Nasihat',
                            icon: Icon(
                              Icons.menu_book_outlined,
                            ),
                            label: Text('Nasihat'),
                          ),
                          ButtonSegment<String>(
                            value: 'Persahabatan',
                            icon: Icon(
                              Icons.people_outline_rounded,
                            ),
                            label: Text('Sahabat'),
                          ),
                        ],
                        selected: <String>{
                          selectedTheme,
                        },
                        onSelectionChanged: _isLoading
                            ? null
                            : (Set<String> value) {
                          setState(() {
                            selectedTheme =
                                value.first;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: paper,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2D3B8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gunakan lokasi / majlis',
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    color: deepMaroon,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Jadikan pantun lebih bermakna',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: useLocation,
                            activeTrackColor: maroon,
                            onChanged: _isLoading
                                ? null
                                : (bool value) {
                              setState(() {
                                useLocation = value;

                                if (!value) {
                                  locationCtrl.clear();
                                  _locationError = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    if (useLocation) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: locationCtrl,
                        enabled: !_isLoading,
                        textCapitalization:
                        TextCapitalization.words,
                        textInputAction:
                        TextInputAction.done,
                        maxLength: 80,
                        onChanged: _validateLocation,
                        onSubmitted: (_) {
                          if (!_isLoading) {
                            _generatePantun();
                          }
                        },
                        decoration: appInput(
                          'Contoh: Johor Bahru / Hari Ibu',
                        ).copyWith(
                          errorText: _locationError,
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: maroon,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    AppButton(
                      label: _isLoading
                          ? 'SEDANG MENJANA...'
                          : 'JANA PANTUN',
                      icon: Icons.auto_awesome,
                      onPressed: () {
                        if (!_isLoading) {
                          _generatePantun();
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'Pantun dijana berdasarkan kata kunci, mood dan tema pilihan anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7D6D61),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading,
          child: _buildContent(),
        ),

        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: paper,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: maroon,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'AI sedang mencipta pantun...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: deepMaroon,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Proses ini mungkin mengambil beberapa saat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7D6D61),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}