import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'moodly_app_bar.dart';
import 'moodly_bottom_nav.dart';
import 'moodly_nav_rail.dart';

/// The single scaffold every top-level screen (Calendar, Log, Insights,
/// Settings) is built on. Handles the responsive switch between a
/// bottom nav bar (mobile) and a side nav rail (tablet/web/desktop) so
/// individual screens never have to think about layout adaptation.
class MoodlyScaffold extends StatelessWidget {
  const MoodlyScaffold({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
    required this.body,
    this.floatingActionButton,
  });

  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    final content = SafeArea(
      child: Responsive.centeredContent(context: context, child: body),
    );

    if (isMobile) {
      return Scaffold(
        appBar: const MoodlyAppBar(),
        body: content,
        bottomNavigationBar: MoodlyBottomNav(
          currentIndex: currentIndex,
          onTap: onNavTap,
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    // Tablet / web / desktop: side rail instead of bottom bar.
    return Scaffold(
      appBar: const MoodlyAppBar(),
      body: Row(
        children: [
          MoodlyNavRail(
            currentIndex: currentIndex,
            onTap: onNavTap,
            extended: isDesktop,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
