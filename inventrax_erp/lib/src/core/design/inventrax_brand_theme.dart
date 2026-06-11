import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Adaptive brand tokens exposed through [ThemeData.extensions].
@immutable
class InventraXBrandTheme extends ThemeExtension<InventraXBrandTheme> {
  const InventraXBrandTheme({
    required this.teal,
    required this.navy,
    required this.sidebarBackground,
    required this.sidebarActive,
    required this.sidebarText,
    required this.heroGradientStart,
    required this.heroGradientEnd,
    required this.actionBackground,
    required this.onAction,
  });

  final Color teal;
  final Color navy;
  final Color sidebarBackground;
  final Color sidebarActive;
  final Color sidebarText;
  final Color heroGradientStart;
  final Color heroGradientEnd;
  final Color actionBackground;
  final Color onAction;

  static const light = InventraXBrandTheme(
    teal: AppColors.brandTeal,
    navy: AppColors.brandNavy,
    sidebarBackground: AppColors.brandNavy,
    sidebarActive: AppColors.brandTeal,
    sidebarText: Colors.white,
    heroGradientStart: AppColors.brandNavy,
    heroGradientEnd: AppColors.brandNavyMid,
    actionBackground: AppColors.brandTeal,
    onAction: Colors.white,
  );

  static const dark = InventraXBrandTheme(
    teal: AppColors.brandTealBright,
    navy: AppColors.brandNavy,
    sidebarBackground: AppColors.brandNavyDeep,
    sidebarActive: AppColors.brandTealBright,
    sidebarText: Colors.white,
    heroGradientStart: AppColors.brandNavyDeep,
    heroGradientEnd: AppColors.brandNavy,
    actionBackground: AppColors.brandTealBright,
    onAction: AppColors.brandNavyDeep,
  );

  /// Navy base with a subtle teal wash — matches InventraX icon pairing.
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          heroGradientStart,
          Color.lerp(heroGradientEnd, teal, 0.22)!,
        ],
      );

  /// Thin accent line color for hero banners (logo √ motif).
  Color get heroAccentLine => teal.withValues(alpha: 0.85);

  @override
  InventraXBrandTheme copyWith({
    Color? teal,
    Color? navy,
    Color? sidebarBackground,
    Color? sidebarActive,
    Color? sidebarText,
    Color? heroGradientStart,
    Color? heroGradientEnd,
    Color? actionBackground,
    Color? onAction,
  }) {
    return InventraXBrandTheme(
      teal: teal ?? this.teal,
      navy: navy ?? this.navy,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarActive: sidebarActive ?? this.sidebarActive,
      sidebarText: sidebarText ?? this.sidebarText,
      heroGradientStart: heroGradientStart ?? this.heroGradientStart,
      heroGradientEnd: heroGradientEnd ?? this.heroGradientEnd,
      actionBackground: actionBackground ?? this.actionBackground,
      onAction: onAction ?? this.onAction,
    );
  }

  @override
  InventraXBrandTheme lerp(ThemeExtension<InventraXBrandTheme>? other, double t) {
    if (other is! InventraXBrandTheme) return this;
    return InventraXBrandTheme(
      teal: Color.lerp(teal, other.teal, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      sidebarBackground: Color.lerp(sidebarBackground, other.sidebarBackground, t)!,
      sidebarActive: Color.lerp(sidebarActive, other.sidebarActive, t)!,
      sidebarText: Color.lerp(sidebarText, other.sidebarText, t)!,
      heroGradientStart: Color.lerp(heroGradientStart, other.heroGradientStart, t)!,
      heroGradientEnd: Color.lerp(heroGradientEnd, other.heroGradientEnd, t)!,
      actionBackground: Color.lerp(actionBackground, other.actionBackground, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
    );
  }
}

extension InventraXBrandThemeContext on BuildContext {
  InventraXBrandTheme get brand =>
      Theme.of(this).extension<InventraXBrandTheme>() ?? InventraXBrandTheme.light;
}
