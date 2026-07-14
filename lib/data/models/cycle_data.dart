import 'package:flutter/foundation.dart';

/// The four phases of a menstrual cycle, used to drive phase labels and
/// progress indicators on the Calendar and Insights screens.
enum CyclePhase {
  menstrual('Menstrual Phase'),
  follicular('Follicular Phase'),
  ovulation('Ovulation'),
  luteal('Luteal Phase');

  const CyclePhase(this.label);

  final String label;
}

/// Core cycle-tracking state: when the last period started, the user's
/// average cycle length, and derived values (current day, phase,
/// regularity) used across Calendar and Insights.
@immutable
class CycleData {
  const CycleData({
    required this.averageCycleLengthDays,
    required this.lastPeriodStartDate,
    required this.regularityPercent,
    this.loggedDates = const {},
  });

  final int averageCycleLengthDays;
  final DateTime lastPeriodStartDate;
  final int regularityPercent;

  /// Dates the user has already submitted a check-in for (drives the
  /// "Logged" dots on the Calendar screen).
  final Set<DateTime> loggedDates;

  /// 1-indexed day within the current cycle, relative to today.
  int get currentDay {
    final today = DateTime.now();
    final diff = _dateOnly(today)
        .difference(_dateOnly(lastPeriodStartDate))
        .inDays;
    if (diff < 0) return 1;
    return (diff % averageCycleLengthDays) + 1;
  }

  int get daysUntilNextPeriod {
    final remaining = averageCycleLengthDays - currentDay;
    return remaining < 0 ? 0 : remaining;
  }

  DateTime get nextPeriodStartDate =>
      _dateOnly(lastPeriodStartDate)
          .add(Duration(days: averageCycleLengthDays));

  /// Very simplified phase estimation for demo purposes:
  /// days 1-5 menstrual, 6-13 follicular, 14-16 ovulation, rest luteal.
  CyclePhase get phase {
    final day = currentDay;
    if (day <= 5) return CyclePhase.menstrual;
    if (day <= 13) return CyclePhase.follicular;
    if (day <= 16) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  double get cycleProgress => currentDay / averageCycleLengthDays;

  CycleData copyWith({
    int? averageCycleLengthDays,
    DateTime? lastPeriodStartDate,
    int? regularityPercent,
    Set<DateTime>? loggedDates,
  }) {
    return CycleData(
      averageCycleLengthDays:
      averageCycleLengthDays ?? this.averageCycleLengthDays,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      regularityPercent: regularityPercent ?? this.regularityPercent,
      loggedDates: loggedDates ?? this.loggedDates,
    );
  }
}

/// Strips the time-of-day component so day-based diffs are accurate
/// regardless of what time "now" is.
DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
