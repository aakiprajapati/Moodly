import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../onboarding/onboarding_screen.dart';
import '../providers/cycle_provider.dart';
import '../providers/view_state.dart';
import '../root/root_shell.dart';

/// First screen shown on launch. Kicks off [CycleProvider.loadInitialData]
/// and routes to Onboarding (first-time users) or the main app shell
/// (returning users) once loading finishes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final provider = context.read<CycleProvider>();
    await provider.loadInitialData();

    // Small delay so the splash animation/branding is actually visible
    // rather than flashing by instantly on fast loads.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final destination = provider.state == ViewState.loaded &&
        provider.hasOnboarded
        ? const RootShell()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Responsive.centeredContent(
          context: context,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.pagePadding(context),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Moon + lotus mark. Swap for the real exported asset
                  // at assets/images/logo_mark.png when available.
                  Image.asset(
                    'assets/images/moodlylogo.png',
                    width: 96,
                    height: 96,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Moodly', style: AppTextStyles.logo(fontSize: 40)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Track your cycles today!',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusPill),
                    child: SizedBox(
                      width: 200,
                      height: 6,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.surfaceCardLight,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primaryRose,
                        ),
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
}
