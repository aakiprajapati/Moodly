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
    final dayOnly = DateTime(day.year, day.month, day.day);
    return !dayOnly.isBefore(nextStart) && dayOnly.isBefore(predictedEnd);
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
              // Extra vertical room so the "Today" label fits under the
              // circle without overflowing the cell.
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              // Computing the real DateTime this way (instead of a bare
              // day-number) lets DateTime itself handle month rollover,
              // so overflow cells (28, 29, 30 before the 1st; the
              // trailing "1") get correct real dates and can still show
              // logged/predicted markers, matching the Figma where the
              // dotted prediction range crosses into next month.
              final cellDate =
              firstDayOfMonth.add(Duration(days: index - leadingBlanks));
              final isInCurrentMonth = cellDate.month == _visibleMonth.month;

              final isToday = _isSameDay(cellDate, today);
              final logged = _isLogged(cellDate);
              final predicted = _isPredicted(cellDate);

              return _DayCell(
                label: cellDate.day.toString(),
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
    // Today always shows light pink, even if it also happens to be a
    // logged day; logged (non-today) days show dark pink.
    final Color? fillColor = isToday
        ? AppColors.surfaceCardLight
        : logged
        ? AppColors.deepRose
        : null;

    // Text color must follow the actual fill shown above, not the raw
    // `logged` flag — otherwise a logged "today" gets light-pink fill
    // but cream (textOnRose) text, which is nearly invisible.
    final textColor = !isInCurrentMonth
        ? AppColors.textMuted.withOpacity(0.4)
        : fillColor == AppColors.deepRose
        ? AppColors.textOnRose
        : AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Reserve room for the "Today" label so the circle never has
          // to compete with it for space — this is what was causing
          // both the overflow and the squashed/non-circular shape.
          final labelHeight = isToday ? 14.0 : 0.0;
          final circleSize =
          (constraints.maxHeight - labelHeight).clamp(0.0, constraints.maxWidth);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (fillColor != null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: fillColor,
                        ),
                      ),
                    if (predicted)
                      CustomPaint(
                        size: Size(circleSize, circleSize),
                        painter:
                        _DashedCirclePainter(color: AppColors.primaryRose),
                      ),
                    Text(
                      label,
                      style: AppTextStyles.body
                          .copyWith(color: textColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Text(
                  'Today',
                  style: AppTextStyles.label.copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Draws a dashed circle outline — Flutter has no built-in dashed
/// [Border], so this hand-rolls one for the "predicted" day markers.
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = (size.shortestSide - paint.strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 16;
    const dashFraction = 0.6; // portion of each segment that's "on"

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i / dashCount) * 2 * 3.141592653589793;
      final sweepAngle =
          (1 / dashCount) * 2 * 3.141592653589793 * dashFraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
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