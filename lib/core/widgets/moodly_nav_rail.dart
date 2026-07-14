import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'nav_destination.dart';

/// Side navigation rail shown on tablet, web, and desktop widths, so the
/// same four destinations from [MoodlyBottomNav] remain reachable
/// without wasting horizontal space on large screens.
class MoodlyNavRail extends StatelessWidget {
  const MoodlyNavRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceCard,
      child: NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        extended: extended,
        minExtendedWidth: 180,
        backgroundColor: AppColors.surfaceCard,
        selectedIconTheme: const IconThemeData(color: AppColors.textOnRose),
        unselectedIconTheme: const IconThemeData(color: AppColors.deepRose),
        selectedLabelTextStyle:
        AppTextStyles.navLabel.copyWith(color: AppColors.deepRose),
        unselectedLabelTextStyle: AppTextStyles.navLabel,
        useIndicator: true,
        indicatorColor: AppColors.primaryRose,
        destinations: MoodlyDestination.values
            .map(
              (d) => NavigationRailDestination(
            icon: Icon(d.icon),
            label: Text(d.label),
          ),
        )
            .toList(),
      ),
    );
  }
}
