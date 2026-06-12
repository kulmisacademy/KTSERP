import 'package:flutter/material.dart';

/// Breakpoints: mobile &lt; 768, tablet 768–1199, desktop ≥ 1200.
abstract final class Responsive {
  static const mobileBreakpoint = 768.0;
  static const tabletBreakpoint = 1200.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isWideLayout(BuildContext context) => !isMobile(context);

  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.all(
        isMobile(context) ? 12 : 24,
      );

  static EdgeInsets pagePaddingHorizontal(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: isMobile(context) ? 12 : 24,
      );

  static double pageInset(BuildContext context) =>
      isMobile(context) ? 12 : 24;

  static int gridCrossCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 5;
  }

  static double titleFontSize(BuildContext context, {double desktop = 28}) =>
      isMobile(context) ? 16 : desktop;

  static double subtitleFontSize(BuildContext context, {double desktop = 18}) =>
      isMobile(context) ? 14 : desktop;

  static double dialogInset(BuildContext context) =>
      isMobile(context) ? 12 : 24;

  static int formColumns(BuildContext context) => isMobile(context) ? 1 : 2;
}
