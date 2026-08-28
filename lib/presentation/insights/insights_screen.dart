import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/mood_entry.dart';
import '../providers/cycle_provider.dart';
import '../providers/view_state.dart';
import 'widgets/cycle_day_ring.dart';
import 'widgets/cycle_glance_row.dart';
import 'widgets/mood_trends_card.dart';

/// Insights tab: cycle-at-a-glance stats, the day ring, and mood trend
/// bars computed from the user's actual logged [MoodEntry] history.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // TODO: AppColors only defines moodCalm/moodEnergetic/moodTired.
  // Swap these placeholder colors for real design-system colors once
  // you add named constants for the other three moods.
  static const Map<MoodType, Color> _moodColors = {
    MoodType.happy: Color(0xFFF2B705),
    MoodType.tired: AppColors.moodTired,
    MoodType.anxious: Color(0xFF7E57C2),
    MoodType.calm: AppColors.moodCalm,
    MoodType.irritated: Color(0xFFE0704A),
    MoodType.angry: Color(0xFFD9453D),
  };

  /// Builds (label, percent, color) trend rows for ALL mood types, most
  /// frequent first. Moods with no logged entries still show, at 0%.
  List<(String, int, Color)> _computeTrends(List<MoodEntry> entries) {
    final counts = <MoodType, int>{
      for (final mood in MoodType.values) mood: 0,
    };
    var totalWithMood = 0;

    for (final entry in entries) {
      final mood = entry.mood;
      if (mood == null) continue;
      counts[mood] = counts[mood]! + 1;
      totalWithMood++;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .map((e) => (
    e.key.label,
    totalWithMood == 0 ? 0 : ((e.value / totalWithMood) * 100).round(),
    _moodColors[e.key] ?? AppColors.deepRose,
    ))
        .toList();
  }

  /// A simple dynamic insight line based on the single most-logged mood.
  /// Returns null if no moods have been logged yet.
  String? _computeInsightTip(List<MoodEntry> entries) {
    final hasAnyMood = entries.any((e) => e.mood != null);
    if (!hasAnyMood) return null;

    final trends = _computeTrends(entries);
    final top = trends.first;
    return "You've felt '${top.$1}' most often — logged on ${top.$2}% "
        'of your check-ins.';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case ViewState.initial:
          case ViewState.loading:
            return const LoadingView(message: 'Crunching your insights...');
          case ViewState.error:
            return ErrorView(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: provider.loadInitialData,
            );
          case ViewState.empty:
            return const EmptyView(
              message: 'Log a few days to start seeing insights here.',
              icon: Icons.insights_outlined,
            );
          case ViewState.loaded:
            final cycleData = provider.cycleData;
            if (cycleData == null) {
              return const EmptyView(
                message: 'Log a few days to start seeing insights here.',
                icon: Icons.insights_outlined,
              );
            }

            final hasAnyMood =
            provider.moodEntries.any((e) => e.mood != null);
            final trends = _computeTrends(provider.moodEntries);

            if (!hasAnyMood) {
              // We still have cycle stats, but no mood history yet —
              // show the glance/ring, and an empty state for trends.
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.pagePadding(context),
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Cycle at a Glance',
                        style: AppTextStyles.scriptHeading()),
                    const SizedBox(height: AppSpacing.md),
                    CycleGlanceRow(
                      averageLengthDays: cycleData.averageCycleLengthDays,
                      regularityPercent: cycleData.regularityPercent,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CycleDayRing(cycleData: cycleData),
                    const SizedBox(height: AppSpacing.xl),
                    const EmptyView(
                      message: 'No mood entries logged yet. Add a daily '
                          'check-in to see your trends here.',
                      icon: Icons.mood_outlined,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.pagePadding(context),
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Cycle at a Glance',
                      style: AppTextStyles.scriptHeading()),
                  const SizedBox(height: AppSpacing.md),
                  CycleGlanceRow(
                    averageLengthDays: cycleData.averageCycleLengthDays,
                    regularityPercent: cycleData.regularityPercent,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CycleDayRing(cycleData: cycleData),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mood Trends', style: AppTextStyles.scriptHeading()),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRose,
                          borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          'All Time',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textOnRose, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MoodTrendsCard(
                    trends: trends,
                    insightTip: _computeInsightTip(provider.moodEntries),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRose,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline,
                            color: AppColors.textOnRose),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'You are not alone! 65% of women face similar '
                                'energy shifts in the ${cycleData.phase.label}',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textOnRose),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}