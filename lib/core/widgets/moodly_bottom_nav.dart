import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'nav_destination.dart';

/// Bottom navigation bar matching the Figma design: rose pill highlight
/// behind the active tab, script-adjacent serif labels.
///
/// Used on mobile/small-tablet widths. See [MoodlyNavRail] for the
/// large-screen equivalent.
class MoodlyBottomNav extends StatelessWidget {
  const MoodlyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(MoodlyDestination.values.length, (index) {
            final destination = MoodlyDestination.values[index];
            final isActive = index == currentIndex;
            return _NavItem(
              destination: destination,
              isActive: isActive,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final MoodlyDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRose : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              destination.icon,
              size: 22,
              color: isActive ? AppColors.textOnRose : AppColors.deepRose,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: AppTextStyles.navLabel.copyWith(
                color: isActive ? AppColors.textOnRose : AppColors.deepRose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
