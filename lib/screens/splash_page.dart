import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';

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
        Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
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
