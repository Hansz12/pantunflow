import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akaun berjaya didaftarkan! Sila log masuk.')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Ralat pendaftaran')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                      const Text('Daftar Akaun Baru\nPantunFlow', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, height: 1.2, fontWeight: FontWeight.w800, color: deepMaroon)),
                      const SizedBox(height: 26),
                      TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: appInput('Email')),
                      const SizedBox(height: 13),
                      TextField(controller: passwordCtrl, obscureText: true, decoration: appInput('Password (Min 6 aksara)', suffix: Icons.visibility_off_outlined)),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator(color: maroon)
                          : AppButton(label: 'DAFTAR', onPressed: _register),
                      const SizedBox(height: 11),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Sudah ada akaun? Log masuk', style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
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