import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/mood_entry.dart';
import '../providers/cycle_provider.dart';
import 'widgets/mood_selector.dart';
import 'widgets/symptom_chip_list.dart';

/// Daily Check-in tab: mood selector, symptom chips, and free-form
/// notes, saved via [CycleProvider.saveMoodEntry].
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  MoodType? _selectedMood;
  final Set<Symptom> _selectedSymptoms = {};
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFromExistingEntry(BuildContext context) {
    if (_prefilled) return;
    final existing = context.read<CycleProvider>().todaysEntry;
    if (existing != null) {
      _selectedMood = existing.mood;
      _selectedSymptoms.addAll(existing.symptoms);
      _notesController.text = existing.notes;
    }
    _prefilled = true;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final entry = MoodEntry(
      date: DateTime.now(),
      mood: _selectedMood,
      symptoms: _selectedSymptoms,
      notes: _notesController.text.trim(),
    );

    final success = await context.read<CycleProvider>().saveMoodEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Entry saved for today.'
              : context.read<CycleProvider>().errorMessage ??
              'Could not save entry.',
        ),
        backgroundColor: success ? AppColors.primaryRose : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _prefillFromExistingEntry(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Check-In', style: AppTextStyles.scriptHeading()),
                const SizedBox(height: AppSpacing.md),
                Text('How are you feeling today?', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Take a moment to reflect on your current mental state '
                      'and physical symptoms.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.lg),
                MoodSelector(
                  selected: _selectedMood,
                  onSelected: (mood) => setState(() => _selectedMood = mood),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Current Symptoms', style: AppTextStyles.scriptHeading()),
          const SizedBox(height: AppSpacing.md),
          SymptomChipList(
            selected: _selectedSymptoms,
            onToggle: (symptom) => setState(() {
              if (_selectedSymptoms.contains(symptom)) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
              }
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Notes', style: AppTextStyles.scriptHeading()),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Describe how you are feeling today...',
                    fillColor: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation(AppColors.textOnRose),
              ),
            )
                : const Text('Save Entry'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
