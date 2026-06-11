import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) => [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.35 : 0.06,
          ),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> elevated(Brightness brightness) => [
        BoxShadow(
          color: AppColors.accent.withValues(
            alpha: brightness == Brightness.dark ? 0.2 : 0.14,
          ),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> subtle(Brightness brightness) => [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: brightness == Brightness.dark ? 0.25 : 0.04,
          ),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
