import 'package:flutter/material.dart';

import 'screens/splash_page.dart';
import 'theme/app_theme.dart';

class PantunFlowApp extends StatelessWidget {
  const PantunFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantunFlow',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
