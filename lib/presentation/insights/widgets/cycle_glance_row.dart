import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Two stat cards ("Avg. Length", "Regularity") shown under the
/// "Cycle at a Glance" heading on the Insights screen.
class CycleGlanceRow extends StatelessWidget {
  const CycleGlanceRow({
    super.key,
    required this.averageLengthDays,
    required this.regularityPercent,
  });

  final int averageLengthDays;
  final int regularityPercent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: 'Avg. Length',
            value: '$averageLengthDays',
            unit: 'days',
            caption: 'Consistent with your baseline',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.star_border,
            label: 'Regularity',
            value: '$regularityPercent',
            unit: '%',
            caption: 'Highly predictable cycles',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.deepRose),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTextStyles.statNumber),
                TextSpan(text: ' $unit', style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(caption, style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
