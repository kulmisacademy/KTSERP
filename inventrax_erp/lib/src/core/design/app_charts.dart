import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand-aligned chart and KPI colors — teal + navy only (no orphan purples/blues).
abstract final class AppCharts {
  static Color sales(Brightness brightness) => AppColors.action(brightness);

  static Color revenue(Brightness brightness) => AppColors.action(brightness);

  static Color profit(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.brandTealBright : AppColors.brandTeal;

  static Color structural(Brightness brightness) =>
      brightness == Brightness.dark ? AppColors.brandNavyMid : AppColors.brandNavy;

  static Color fill(Brightness brightness) =>
      AppColors.action(brightness).withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.22);

  static Color expenses() => AppColors.warning;

  static Color inventory(Brightness brightness) =>
      Color.lerp(
        AppColors.brandNavyMid,
        AppColors.brandTeal,
        brightness == Brightness.dark ? 0.35 : 0.25,
      )!;

  static Color neutral(Brightness brightness) =>
      brightness == Brightness.dark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight;

  static List<Color> seriesPalette(Brightness brightness) => [
        sales(brightness),
        structural(brightness),
        expenses(),
        inventory(brightness),
      ];
}
