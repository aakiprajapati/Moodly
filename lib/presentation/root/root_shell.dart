import 'package:flutter/material.dart';
import '../../core/widgets/moodly_scaffold.dart';
import '../calendar/calendar_screen.dart';
import '../insights/insights_screen.dart';
import '../log/log_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the four main tabs (Calendar, Log, Insights, Settings) behind
/// a single [MoodlyScaffold], preserving each tab's scroll position via
/// [IndexedStack] when switching between them.
class RootShell extends StatefulWidget {
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _currentIndex = widget.initialIndex;

  static const _screens = [
    CalendarScreen(),
    LogScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MoodlyScaffold(
      currentIndex: _currentIndex,
      onNavTap: (index) => setState(() => _currentIndex = index),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
