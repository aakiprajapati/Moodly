import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../providers/cycle_provider.dart';
import '../root/root_shell.dart';

/// First-run screen collecting the two inputs needed to start tracking:
/// average cycle length and the last period's start date.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _cycleLengthController = TextEditingController(text: '28');
  DateTime? _lastPeriodDate;
  bool _isSaving = false;
  String? _validationError;

  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryRose,
              onPrimary: AppColors.textOnRose,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _lastPeriodDate = picked);
    }
  }

  Future<void> _submit() async {
    final cycleLength = int.tryParse(_cycleLengthController.text.trim());

    if (cycleLength == null || cycleLength <= 0) {
      setState(() => _validationError = 'Enter a valid cycle length.');
      return;
    }
    if (_lastPeriodDate == null) {
      setState(() => _validationError = 'Select your last period start date.');
      return;
    }

    setState(() {
      _validationError = null;
      _isSaving = true;
    });

    final success = await context.read<CycleProvider>().completeOnboarding(
      averageCycleLengthDays: cycleLength,
      lastPeriodStartDate: _lastPeriodDate!,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootShell()),
      );
    } else {
      setState(() {
        _validationError = context.read<CycleProvider>().errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Responsive.centeredContent(
          context: context,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text('Moodly', style: AppTextStyles.logo(fontSize: 36)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceCard,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline,
                      color: AppColors.deepRose),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Your data, Your space', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Average cycle length (days)',
                          style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _cycleLengthController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Last Period Start Date',
                          style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.calendar_today_outlined,
                                color: AppColors.deepRose),
                          ),
                          child: Text(
                            _lastPeriodDate == null
                                ? 'mm/dd/yyyy'
                                : DateFormat('MM/dd/yyyy')
                                .format(_lastPeriodDate!),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: _lastPeriodDate == null
                                  ? AppColors.textMuted
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _validationError!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.textOnRose,
                        ),
                      ),
                    )
                        : const Text('Get Started'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Privacy Policy',
                        style: AppTextStyles.bodyMuted
                            .copyWith(decoration: TextDecoration.underline)),
                    const SizedBox(width: AppSpacing.lg),
                    Text('Terms of Use',
                        style: AppTextStyles.bodyMuted
                            .copyWith(decoration: TextDecoration.underline)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
