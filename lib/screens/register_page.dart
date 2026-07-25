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
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailPattern.hasMatch(email);
  }

  void _validateEmail(String value) {
    setState(() {
      final String email = value.trim();

      if (email.isEmpty) {
        _emailError = 'Email diperlukan.';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Format email tidak sah.';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password diperlukan.';
      } else if (value.length < 6) {
        _passwordError =
        'Password mestilah sekurang-kurangnya 6 aksara.';
      } else {
        _passwordError = null;
      }

      if (confirmPasswordCtrl.text.isNotEmpty) {
        if (value != confirmPasswordCtrl.text) {
          _confirmPasswordError =
          'Pengesahan password tidak sama.';
        } else {
          _confirmPasswordError = null;
        }
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError =
        'Sila sahkan password anda.';
      } else if (value != passwordCtrl.text) {
        _confirmPasswordError =
        'Pengesahan password tidak sama.';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _validateRegisterForm() {
    final String email = emailCtrl.text.trim();
    final String password = passwordCtrl.text;
    final String confirmPassword = confirmPasswordCtrl.text;

    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email diperlukan.';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Format email tidak sah.';
      } else {
        _emailError = null;
      }

      if (password.isEmpty) {
        _passwordError = 'Password diperlukan.';
      } else if (password.length < 6) {
        _passwordError =
        'Password mestilah sekurang-kurangnya 6 aksara.';
      } else {
        _passwordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError =
        'Sila sahkan password anda.';
      } else if (confirmPassword != password) {
        _confirmPasswordError =
        'Pengesahan password tidak sama.';
      } else {
        _confirmPasswordError = null;
      }
    });

    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  String _getFirebaseRegisterError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Format email tidak sah.';

      case 'email-already-in-use':
        return 'Email ini telah digunakan untuk akaun lain.';

      case 'weak-password':
        return 'Password terlalu lemah. Gunakan sekurang-kurangnya 6 aksara.';

      case 'operation-not-allowed':
        return 'Pendaftaran menggunakan email belum diaktifkan.';

      case 'network-request-failed':
        return 'Tiada sambungan Internet. Sila periksa rangkaian anda.';

      case 'too-many-requests':
        return 'Terlalu banyak percubaan. Sila cuba lagi kemudian.';

      default:
        return 'Pendaftaran tidak berjaya. Sila cuba lagi.';
    }
  }

  Future<void> _showErrorDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                width: 60,
                height: 60,
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
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

  Future<void> _showRegisterSuccessDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pendaftaran Berjaya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepMaroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: const Text(
            'Akaun PantunFlow anda telah berjaya didaftarkan. Sila log masuk menggunakan email dan password anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 160,
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
                  'LOG MASUK',
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_validateRegisterForm()) {
      return;
    }

    final String email = emailCtrl.text.trim();
    final String password = passwordCtrl.text;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firebase secara automatik log masuk selepas pendaftaran.
      // Sign out supaya pengguna perlu log masuk semula.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      setState(() => _isLoading = false);

      await _showRegisterSuccessDialog();

      if (!mounted) return;

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      await _showErrorDialog(
        title: 'Pendaftaran Gagal',
        message: _getFirebaseRegisterError(e.code),
      );
    } catch (_) {
      await _showErrorDialog(
        title: 'Ralat',
        message: 'Ralat tidak dijangka berlaku. Sila cuba lagi.',
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRegisterContent() {
    return BatikBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                22,
              ),
              decoration: BoxDecoration(
                color: paper,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3D3B1C0E),
                    blurRadius: 18,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const PantunMark(size: 62),
                  const SizedBox(height: 14),

                  const Text(
                    'Daftar Akaun Baru\nPantunFlow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: deepMaroon,
                    ),
                  ),

                  const SizedBox(height: 26),

                  TextField(
                    controller: emailCtrl,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: _validateEmail,
                    decoration: appInput('Email').copyWith(
                      errorText: _emailError,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: maroon,
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  TextField(
                    controller: passwordCtrl,
                    enabled: !_isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: _validatePassword,
                    decoration: appInput(
                      'Password (Minimum 6 aksara)',
                    ).copyWith(
                      errorText: _passwordError,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: maroon,
                      ),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Lihat password'
                            : 'Sembunyikan password',
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: maroon,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  TextField(
                    controller: confirmPasswordCtrl,
                    enabled: !_isLoading,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: _validateConfirmPassword,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _register();
                      }
                    },
                    decoration: appInput(
                      'Sahkan Password',
                    ).copyWith(
                      errorText: _confirmPasswordError,
                      prefixIcon: const Icon(
                        Icons.lock_reset_rounded,
                        color: maroon,
                      ),
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirmPassword
                            ? 'Lihat password'
                            : 'Sembunyikan password',
                        onPressed: _isLoading
                            ? null
                            : () {
                          setState(() {
                            _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: maroon,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  AppButton(
                    label: 'DAFTAR',
                    onPressed: () {
                      if (!_isLoading) {
                        _register();
                      }
                    },
                  ),

                  const SizedBox(height: 11),

                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Sudah ada akaun? Log masuk',
                      style: TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: _buildRegisterContent(),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
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
                          'Mendaftarkan akaun...',
                          style: TextStyle(
                            color: deepMaroon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}