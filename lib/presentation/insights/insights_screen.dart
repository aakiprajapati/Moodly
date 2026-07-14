import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/state_views.dart';
import '../providers/cycle_provider.dart';
import '../providers/view_state.dart';
import 'widgets/cycle_day_ring.dart';
import 'widgets/cycle_glance_row.dart';
import 'widgets/mood_trends_card.dart';

/// Insights tab: cycle-at-a-glance stats, the day ring, and mood trend
/// bars. Mood trend percentages are illustrative (would come from
/// aggregating [CycleProvider.moodEntries] once enough history exists).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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

            if (provider.moodEntries.isEmpty) {
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
                          'Last 3 Cycles',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textOnRose, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const MoodTrendsCard(
                    trends: [
                      ('Calm', 52, AppColors.moodCalm),
                      ('Energetic', 36, AppColors.moodEnergetic),
                      ('Tired', 45, AppColors.moodTired),
                    ],
                    insightTip: "You often feel 'Tired' 4 days before your "
                        'cycle starts!',
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
