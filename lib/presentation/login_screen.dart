import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import 'providers/auth_provider.dart';
import 'onboarding/onboarding_screen.dart';
import 'root/root_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final cred = await auth.signInWithGoogle();
      print('SIGN IN RESULT: $cred');
      if (cred == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      final onboarded = await auth.isOnboardedForCurrentUser();
      if (!mounted) return;

      if (onboarded) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RootShell()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = 'Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Responsive.centeredContent(
          context: context,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.pagePadding(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Moodly', style: AppTextStyles.logo(fontSize: 40)),
                const SizedBox(height: AppSpacing.lg),
                Image.asset('assets/images/moodlylogo.png', width: 96, height: 96),
                const SizedBox(height: AppSpacing.xl),
                Text('Sign in to continue', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.md),
                if (_error != null) ...[
                  Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.error)),
                  const SizedBox(height: AppSpacing.md),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.account_circle),
                    label: _isSigningIn
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.textOnRose)))
                        : const Text('Continue with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRose,
                      foregroundColor: AppColors.textOnRose,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('We only use your account to save your data securely.', style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
