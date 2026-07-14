import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_data.dart';

/// "Current Cycle" card at the top of the Calendar screen: current day,
/// days until next period, and a phase progress bar.
class CycleProgressCard extends StatelessWidget {
  const CycleProgressCard({super.key, required this.cycleData});

  final CycleData cycleData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Cycle', style: AppTextStyles.scriptHeading()),
          const SizedBox(height: AppSpacing.sm),
          Text('Day ${cycleData.currentDay.toString().padLeft(2, '0')}',
              style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            text: TextSpan(
              style: AppTextStyles.body,
              children: [
                const TextSpan(text: 'Period expected in '),
                TextSpan(
                  text: '${cycleData.daysUntilNextPeriod} days',
                  style:
                  AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: cycleData.cycleProgress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceCardLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.deepRose),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cycleData.phase.label, style: AppTextStyles.bodyMuted),
              Text('Ovulation', style: AppTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}
