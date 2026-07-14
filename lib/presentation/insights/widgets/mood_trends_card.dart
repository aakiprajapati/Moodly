import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// A single mood-frequency row: name, percentage, and a horizontal bar.
class MoodTrendBar extends StatelessWidget {
  const MoodTrendBar({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: AppSpacing.xs),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
              Text('$percent%', style: AppTextStyles.bodyLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppColors.trendTrack,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Dominant States" card wrapping [MoodTrendBar]s plus an insight tip.
class MoodTrendsCard extends StatelessWidget {
  const MoodTrendsCard({super.key, required this.trends, this.insightTip});

  /// Ordered (label, percent, color) triples.
  final List<(String, int, Color)> trends;
  final String? insightTip;

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
          Text('Dominant States', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text('Your most frequent feelings this quarter',
              style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.md),
          for (final trend in trends)
            MoodTrendBar(label: trend.$1, percent: trend.$2, color: trend.$3),
          if (insightTip != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: AppColors.deepRose),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(insightTip!, style: AppTextStyles.bodyMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
