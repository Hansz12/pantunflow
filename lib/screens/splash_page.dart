import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';
import 'main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    try {
      await _animationController.forward();

      final User? currentUser =
      await FirebaseAuth.instance.authStateChanges().first;

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted || _hasNavigated) {
        return;
      }

      _hasNavigated = true;

      final Widget nextPage = currentUser == null
          ? const LoginPage()
          : const MainShell();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => nextPage,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('SPLASH FLOW ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || _hasNavigated) {
        return;
      }

      _hasNavigated = true;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: BatikBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                    ) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: maroon,
                                      borderRadius:
                                      BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: cream,
                                      size: 72,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'PantunFlow',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: maroon,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Context-Aware AI Pantun',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: deepMaroon,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 34),
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.6,
                              color: maroon,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Memuatkan aplikasi...',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Column(
                  children: [
                    Text(
                      'Pantun Tradisional Bertemu Teknologi AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Versi 1.0.0',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}