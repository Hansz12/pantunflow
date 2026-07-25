import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'main_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailPattern.hasMatch(email);
  }

  void _validateEmail(String value) {
    if (!mounted) return;

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
    if (!mounted) return;

    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password diperlukan.';
      } else if (value.length < 6) {
        _passwordError =
        'Password mestilah sekurang-kurangnya 6 aksara.';
      } else {
        _passwordError = null;
      }
    });
  }

  bool _validateLoginForm() {
    final String email = emailCtrl.text.trim();
    final String password = passwordCtrl.text;

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
    });

    return _emailError == null && _passwordError == null;
  }

  String _getFirebaseLoginError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Format email tidak sah.';

      case 'user-disabled':
        return 'Akaun ini telah dinyahaktifkan.';

      case 'user-not-found':
        return 'Akaun menggunakan email ini tidak dijumpai.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password tidak betul.';

      case 'too-many-requests':
        return 'Terlalu banyak percubaan log masuk. Cuba lagi kemudian.';

      case 'network-request-failed':
        return 'Tiada sambungan Internet. Sila periksa rangkaian anda.';

      case 'operation-not-allowed':
        return 'Kaedah log masuk ini belum diaktifkan.';

      default:
        return 'Log masuk tidak berjaya. Sila cuba lagi.';
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
            mainAxisSize: MainAxisSize.min,
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

  Future<void> _showSuccessDialog({
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
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

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validateLoginForm()) {
      return;
    }

    final String email = emailCtrl.text.trim();
    final String password = passwordCtrl.text;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      await _showErrorDialog(
        title: 'Log Masuk Gagal',
        message: _getFirebaseLoginError(e.code),
      );
    } catch (_) {
      await _showErrorDialog(
        title: 'Ralat',
        message: 'Ralat tidak dijangka berlaku. Sila cuba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const MainShell(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      await _showErrorDialog(
        title: 'Google Sign-In Gagal',
        message: _getFirebaseLoginError(e.code),
      );
    } catch (e, stackTrace) {
      debugPrint('GOOGLE SIGN-IN ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      await _showErrorDialog(
        title: 'Google Sign-In Gagal',
        message:
        'Log masuk menggunakan Google tidak berjaya. Sila cuba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    String resetEmail = emailCtrl.text.trim();
    String? resetEmailError;

    final bool? shouldSend = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
              BuildContext context,
              StateSetter setDialogState,
              ) {
            void validateResetEmail(String value) {
              final String email = value.trim();

              setDialogState(() {
                resetEmail = email;

                if (email.isEmpty) {
                  resetEmailError = 'Email diperlukan.';
                } else if (!_isValidEmail(email)) {
                  resetEmailError = 'Format email tidak sah.';
                } else {
                  resetEmailError = null;
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    color: maroon,
                    size: 46,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Lupa Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: deepMaroon,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masukkan email anda. Pautan reset password akan dihantar melalui email.',
                    style: TextStyle(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: resetEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: validateResetEmail,
                    onFieldSubmitted: (String value) {
                      validateResetEmail(value);

                      if (resetEmailError == null) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    },
                    decoration: appInput('Email').copyWith(
                      errorText: resetEmailError,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: maroon,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text(
                    'BATAL',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String email = resetEmail.trim();

                    setDialogState(() {
                      if (email.isEmpty) {
                        resetEmailError = 'Email diperlukan.';
                      } else if (!_isValidEmail(email)) {
                        resetEmailError =
                        'Format email tidak sah.';
                      } else {
                        resetEmailError = null;
                      }
                    });

                    if (resetEmailError == null) {
                      resetEmail = email;
                      Navigator.of(dialogContext).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'HANTAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSend != true) {
      return;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: resetEmail,
      );

      if (!mounted) return;

      await _showSuccessDialog(
        title: 'Email Dihantar',
        message:
        'Pautan reset password telah dihantar. Sila periksa peti masuk atau folder spam email anda.',
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Format email tidak sah.';
          break;

        case 'user-not-found':
          message =
          'Tiada akaun didaftarkan menggunakan email ini.';
          break;

        case 'too-many-requests':
          message =
          'Terlalu banyak permintaan. Cuba lagi kemudian.';
          break;

        case 'network-request-failed':
          message =
          'Tiada sambungan Internet. Sila periksa rangkaian anda.';
          break;

        default:
          message =
          'Pautan reset password tidak dapat dihantar.';
      }

      await _showErrorDialog(
        title: 'Reset Password Gagal',
        message: message,
      );
    } catch (_) {
      await _showErrorDialog(
        title: 'Ralat',
        message: 'Ralat tidak dijangka berlaku. Sila cuba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLoginContent() {
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
                    'Selamat Datang ke\nPantunFlow',
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
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: _validatePassword,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _login();
                      }
                    },
                    decoration: appInput('Password').copyWith(
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                      _isLoading ? null : _forgotPassword,
                      child: const Text(
                        'Lupa password?',
                        style: TextStyle(
                          color: maroon,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  AppButton(
                    label: 'LOG MASUK',
                    onPressed: () {
                      if (!_isLoading) {
                        _login();
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed:
                    _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 30,
                      color: maroon,
                    ),
                    label: const Text(
                      'Log masuk dengan Google',
                      style: TextStyle(
                        color: deepMaroon,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize:
                      const Size(double.infinity, 50),
                      side: const BorderSide(color: maroon),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                          const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Belum ada akaun? Daftar',
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
            child: _buildLoginContent(),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
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
                          'Sila tunggu...',
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