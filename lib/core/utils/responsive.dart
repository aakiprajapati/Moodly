import 'package:flutter/material.dart';

/// Breakpoints and helpers used to adapt layouts across mobile, tablet,
/// web, and desktop. Widths follow common Material breakpoints.
class Responsive {
  Responsive._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  /// Max content width so text/cards don't stretch edge-to-edge on
  /// large screens. Mobile gets full width.
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMax) return 900;
    if (width >= tabletMax) return 720;
    if (width >= mobileMax) return 560;
    return width;
  }

  /// Horizontal page padding that grows slightly on larger screens.
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMax) return 40;
    if (width >= mobileMax) return 28;
    return 20;
  }

  /// Number of grid columns for grid-based layouts (e.g. mood selector,
  /// symptom chips) depending on available width.
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMax) return 4;
    if (width >= mobileMax) return 3;
    return 2;
  }

  /// Wraps a page body so it's centered with a max width on large
  /// screens, while remaining full-bleed on mobile.
  static Widget centeredContent({
    required BuildContext context,
    required Widget child,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentMaxWidth(context)),
        child: child,
      ),
    );
  }
}
