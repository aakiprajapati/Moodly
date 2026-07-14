import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/cycle_data.dart';

/// Month-view calendar grid with logged-day and predicted-day markers,
/// matching the Figma "July 2026" layout.
class CalendarGrid extends StatefulWidget {
  const CalendarGrid({super.key, required this.cycleData});

  final CycleData cycleData;

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late DateTime _visibleMonth =
  DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isLogged(DateTime day) =>
      widget.cycleData.loggedDates.any((d) => _isSameDay(d, day));

  bool _isPredicted(DateTime day) {
    final nextStart = widget.cycleData.nextPeriodStartDate;
    final predictedEnd = nextStart.add(const Duration(days: 4));
    return !day.isBefore(nextStart) && day.isBefore(predictedEnd);
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Sunday-start week, matching the Figma grid (S M T W T F S).
    final leadingBlanks = firstDayOfMonth.weekday % 7;

    final totalCells = leadingBlanks + daysInMonth;
    final trailingBlanks = (7 - (totalCells % 7)) % 7;
    final cellCount = totalCells + trailingBlanks;

    final today = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth),
                style: AppTextStyles.scriptHeading(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppColors.deepRose),
                    onPressed: () => _changeMonth(-1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.deepRose),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
              child: Center(
                child: Text(d, style: AppTextStyles.label),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cellCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - leadingBlanks + 1;
              final isInCurrentMonth =
                  dayNumber >= 1 && dayNumber <= daysInMonth;

              // Only meaningful when isInCurrentMonth is true — marker
              // checks below are always guarded by that flag.
              final cellDate =
              DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);

              final isToday = isInCurrentMonth && _isSameDay(cellDate, today);
              final logged = isInCurrentMonth && _isLogged(cellDate);
              final predicted = isInCurrentMonth && _isPredicted(cellDate);

              return _DayCell(
                label: isInCurrentMonth
                    ? dayNumber.toString()
                    : _outOfMonthLabel(dayNumber, daysInMonth),
                isInCurrentMonth: isInCurrentMonth,
                isToday: isToday,
                logged: logged,
                predicted: predicted,
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _LegendDot(
                  filled: true, label: 'Logged', color: AppColors.deepRose),
              const SizedBox(width: AppSpacing.lg),
              _LegendDot(
                  filled: false,
                  label: 'Next Prediction',
                  color: AppColors.primaryRose),
            ],
          ),
        ],
      ),
    );
  }

  /// Renders the previous/next month's overflow days (e.g. 28, 29, 30 at
  /// the start, 1 at the end) the way the Figma grid shows them.
  String _outOfMonthLabel(int dayNumber, int daysInCurrentMonth) {
    if (dayNumber < 1) {
      final prevMonthLastDay =
          DateTime(_visibleMonth.year, _visibleMonth.month, 0).day;
      return (prevMonthLastDay + dayNumber).toString();
    }
    return (dayNumber - daysInCurrentMonth).toString();
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.isInCurrentMonth,
    required this.isToday,
    required this.logged,
    required this.predicted,
  });

  final String label;
  final bool isInCurrentMonth;
  final bool isToday;
  final bool logged;
  final bool predicted;

  @override
  Widget build(BuildContext context) {
    final textColor = !isInCurrentMonth
        ? AppColors.textMuted.withOpacity(0.4)
        : logged
        ? AppColors.textOnRose
        : AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: logged ? AppColors.deepRose : Colors.transparent,
            border: predicted
                ? Border.all(color: AppColors.primaryRose, width: 1.5)
                : isToday
                ? Border.all(color: AppColors.deepRose, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.filled,
    required this.label,
    required this.color,
  });

  final bool filled;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: filled ? null : Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodyMuted),
      ],
    );
  }
}
