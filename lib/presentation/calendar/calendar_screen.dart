import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/cycle_data.dart';
import '../providers/cycle_provider.dart';
import '../providers/view_state.dart';
import '../root/root_shell.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/cycle_progress_card.dart';

/// Home tab: current cycle summary + month calendar with logged /
/// predicted day markers. A floating "+" button jumps to the Log tab.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case ViewState.initial:
          case ViewState.loading:
            return const LoadingView(message: 'Loading your cycle...');
          case ViewState.error:
            return ErrorView(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: provider.loadInitialData,
            );
          case ViewState.empty:
            return const EmptyView(
              message: 'No cycle data yet. Complete onboarding to get '
                  'started.',
            );
          case ViewState.loaded:
            final cycleData = provider.cycleData;
            if (cycleData == null) {
              return const EmptyView(
                message: 'No cycle data yet. Complete onboarding to get '
                    'started.',
              );
            }
            return _CalendarContent(cycleData: cycleData);
        }
      },
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.cycleData});

  final CycleData cycleData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CycleProgressCard(cycleData: cycleData),
              const SizedBox(height: AppSpacing.lg),
              CalendarGrid(cycleData: cycleData),
              const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
            ],
          ),
        ),
        Positioned(
          bottom: AppSpacing.lg,
          right: Responsive.pagePadding(context),
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryRose,
            foregroundColor: AppColors.textOnRose,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            onPressed: () {
              // Jump to the Log tab so the user can add today's entry.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const RootShell(initialIndex: 1),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
