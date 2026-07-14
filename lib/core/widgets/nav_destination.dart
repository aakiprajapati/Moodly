import 'package:flutter/material.dart';

/// The four primary destinations in Moodly. Kept as a single enum so
/// the bottom nav bar (mobile) and the nav rail (tablet/desktop) stay
/// perfectly in sync and route to the same index.
enum MoodlyDestination {
  calendar(icon: Icons.calendar_today_outlined, label: 'Calendar'),
  log(icon: Icons.edit_outlined, label: 'Log'),
  insights(icon: Icons.tune, label: 'Insights'),
  settings(icon: Icons.settings_outlined, label: 'Settings');

  const MoodlyDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
