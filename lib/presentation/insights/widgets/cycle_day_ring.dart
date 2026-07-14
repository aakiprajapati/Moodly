import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_data.dart';

/// The circular "Day 07" indicator flanked by decorative bars, with the
/// current phase pill and description underneath.
class CycleDayRing extends StatelessWidget {
  const CycleDayRing({super.key, required this.cycleData});

  final CycleData cycleData;

  static const Map<CyclePhase, String> _phaseDescriptions = {
    CyclePhase.menstrual:
    'Your body is resetting. Prioritize rest and gentle movement.',
    CyclePhase.follicular: 'Your energy levels are rising. A great time for '
        'focused tasks and creative exploration',
    CyclePhase.ovulation:
    'Energy peaks here. A good window for high-focus activities.',
    CyclePhase.luteal:
    'Energy may dip. Be extra kind to yourself over the next few days.',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SideBars(),
            const SizedBox(width: AppSpacing.lg),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceCard,
                border: Border.all(color: AppColors.deepRose, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                'Day ${cycleData.currentDay.toString().padLeft(2, '0')}',
                style: AppTextStyles.h1,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            const _SideBars(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryRose,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            cycleData.phase.label,
            style: AppTextStyles.label.copyWith(color: AppColors.textOnRose),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _phaseDescriptions[cycleData.phase] ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
      ],
    );
  }
}

class _SideBars extends StatelessWidget {
  const _SideBars();

  @override
  Widget build(BuildContext context) {
    const heights = [24.0, 40.0, 56.0, 40.0, 24.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: heights
          .map(
            (h) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.primaryRose,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
      )
          .toList(),
    );
  }
}
