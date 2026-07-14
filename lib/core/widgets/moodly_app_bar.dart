import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Shared top app bar used on every main screen: hamburger menu,
/// script "Moodly" wordmark, and a notification bell.
///
/// [onMenuTap] and [onBellTap] are optional so screens can wire them up
/// to a drawer/notifications page later without changing this widget.
class MoodlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MoodlyAppBar({
    super.key,
    this.onMenuTap,
    this.onBellTap,
    this.hasNotification = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onBellTap;
  final bool hasNotification;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.deepRose),
        onPressed: onMenuTap,
        tooltip: 'Menu',
      ),
      title: Text('Moodly', style: AppTextStyles.logo()),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: AppColors.deepRose),
              onPressed: onBellTap,
              tooltip: 'Notifications',
            ),
            if (hasNotification)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
