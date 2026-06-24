import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'main_shell.dart';

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
                      AppButton(label: 'LOG MASUK', onPressed: _login),
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
