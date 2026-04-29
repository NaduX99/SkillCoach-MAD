import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // PERFORMANCE FIX: Run auth check and minimum animation time in parallel.
    // Previously, the app waited 3 seconds THEN checked auth, causing slow startup.
    // Now both run simultaneously — app navigates as soon as both are ready.
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Run both tasks in parallel
    final results = await Future.wait([
      _checkAuth(),
      // Minimum splash display time (reduced from 3s to 1.5s)
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);

    final authResult = results[0] as _AuthResult;

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (authResult.isLoggedIn) {
          if (!authResult.emailVerified) {
            context.go('/verify-email');
          } else if (authResult.profileCompleted) {
            context.go('/');
          } else {
            context.go('/profile-setup');
          }
        } else {
          context.go('/login');
        }
      });
    }
  }

  Future<_AuthResult> _checkAuth() async {
    try {
      // PERFORMANCE FIX: Use currentUser instead of authStateChanges().first
      // currentUser is synchronous and avoids waiting for a stream event
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return _AuthResult(
            isLoggedIn: true,
            emailVerified: user.emailVerified,
            profileCompleted: data['profileCompleted'] as bool? ?? false,
          );
        }
        return _AuthResult(
          isLoggedIn: true,
          emailVerified: user.emailVerified,
          profileCompleted: false,
        );
      }
      return _AuthResult(isLoggedIn: false, emailVerified: false, profileCompleted: false);
    } catch (e) {
      debugPrint('Auth check error: $e');
      return _AuthResult(isLoggedIn: false, emailVerified: false, profileCompleted: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coach your skills. Master your future.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthResult {
  final bool isLoggedIn;
  final bool emailVerified;
  final bool profileCompleted;
  _AuthResult({
    required this.isLoggedIn,
    required this.emailVerified,
    required this.profileCompleted,
  });
}
