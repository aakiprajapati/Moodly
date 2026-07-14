import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/mood_entry.dart';

/// Multi-select wrapped chip list for "Current Symptoms".
class SymptomChipList extends StatelessWidget {
  const SymptomChipList({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<Symptom> selected;
  final ValueChanged<Symptom> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: Symptom.values.map((symptom) {
        final isSelected = selected.contains(symptom);
        return ChoiceChip(
          label: Text(symptom.label),
          selected: isSelected,
          onSelected: (_) => onToggle(symptom),
          labelStyle: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.textOnRose : AppColors.textDark,
          ),
          backgroundColor: AppColors.surfaceCardLight,
          selectedColor: AppColors.primaryRose,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            side: BorderSide.none,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
