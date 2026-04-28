import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_theme.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  int _cooldownSeconds = 0;
  Timer? _verificationTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto check every 5 seconds if verified
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerified() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.reloadUser();
      
      if (authService.isEmailVerified) {
        _verificationTimer?.cancel();
        if (mounted) {
          final profileCompleted = await authService.isProfileCompleted();
          if (mounted) {
            if (profileCompleted) {
              context.go('/');
            } else {
              context.go('/profile-setup');
            }
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerification() async {
    if (_cooldownSeconds > 0) return;

    setState(() => _isResending = true);
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: AppTheme.success,
          ),
        );
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('too-many-requests')) {
          errorMsg = 'Too many requests. Please wait a moment before trying again.';
          _startCooldown(); // Force cooldown if Firebase tells us to wait
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authServiceProvider).logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 100,
                    color: AppTheme.accentLight,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Verify Your Email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We have sent a verification link to your email address. Please check your inbox and click the link to continue.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Primary Action: Refresh/Check manually
                  ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkEmailVerified,
                    icon: _isChecking 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.refresh),
                    label: const Text('I Have Verified'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary Action: Resend
                  TextButton.icon(
                    onPressed: (_isResending || _cooldownSeconds > 0) ? null : _resendVerification,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(
                      _isResending 
                        ? 'Sending...' 
                        : (_cooldownSeconds > 0 ? 'Resend in ${_cooldownSeconds}s' : 'Resend Email')
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentLight,
                      disabledForegroundColor: AppTheme.textSecondary.withAlpha(100),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tertiary Action: Back/Log out
                  TextButton(
                    onPressed: _logout,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
