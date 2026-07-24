import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Pastikan import ini ada
import 'screens/login_page.dart';

void main() async {
  // 2. Wajib ada dua baris ini di paling atas main()
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PantunFlow',
      home: LoginPage(),
    );
  }
}