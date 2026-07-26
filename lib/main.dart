import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'screens/login_page.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PantunFlow',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (
            BuildContext context,
            AsyncSnapshot<User?> snapshot,
            ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashLoadingPage();
          }

          if (snapshot.hasError) {
            debugPrint("========== AUTH ERROR ==========");
            debugPrint(snapshot.error.toString());
            debugPrint("=======================================");
            return const LoginPage();
          }

          if (snapshot.hasData) {
            return const MainShell();
          }

          return const LoginPage();
        },
      ),
    );
  }
}

class SplashLoadingPage extends StatelessWidget {
  const SplashLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}