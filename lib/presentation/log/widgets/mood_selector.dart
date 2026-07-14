import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/mood_entry.dart';

/// 2-column (mobile) / responsive grid of mood tiles for the Daily
/// Check-in card. Only one mood can be selected at a time.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MoodType? selected;
  final ValueChanged<MoodType> onSelected;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.isMobile(context) ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MoodType.values.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final mood = MoodType.values[index];
        final isSelected = selected == mood;
        return _MoodTile(
          mood: mood,
          isSelected: isSelected,
          onTap: () => onSelected(mood),
        );
      },
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.deepRose : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(mood.icon, color: AppColors.deepRose, size: 22),
            const SizedBox(height: AppSpacing.xs),
            Text(
              mood.label.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                fontSize: 11,
                color: AppColors.deepRose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
