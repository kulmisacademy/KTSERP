import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Unified status semantics: success, warning, error, info.
enum AppStatusType { success, warning, error, info, neutral }

abstract final class AppStatus {
  static Color color(AppStatusType type, {Brightness? brightness}) {
    return switch (type) {
      AppStatusType.success => AppColors.success,
      AppStatusType.warning => AppColors.warning,
      AppStatusType.error => AppColors.error,
      AppStatusType.info => AppColors.brandTeal,
      AppStatusType.neutral => brightness == Brightness.dark
          ? AppColors.textTertiaryDark
          : AppColors.textTertiaryLight,
    };
  }

  static Color container(AppStatusType type, {Brightness? brightness}) {
    final isDark = brightness == Brightness.dark;
    return switch (type) {
      AppStatusType.success =>
        isDark ? AppColors.success.withValues(alpha: 0.18) : AppColors.successContainer,
      AppStatusType.warning =>
        isDark ? AppColors.warning.withValues(alpha: 0.18) : AppColors.warningContainer,
      AppStatusType.error =>
        isDark ? AppColors.error.withValues(alpha: 0.18) : AppColors.errorContainer,
      AppStatusType.info =>
        isDark ? AppColors.brandTeal.withValues(alpha: 0.18) : AppColors.accentMuted,
      AppStatusType.neutral =>
        isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMutedLight,
    };
  }

  static AppStatusType forSyncHealth(String name) => switch (name) {
        'synced' => AppStatusType.success,
        'syncing' => AppStatusType.info,
        'queued' => AppStatusType.warning,
        'offline' => AppStatusType.error,
        _ => AppStatusType.neutral,
      };

  static AppStatusType forOnline(bool online) =>
      online ? AppStatusType.success : AppStatusType.error;
}
