import 'package:flutter/material.dart';

/// InventraX brand palette — from platform hexagon icon (teal + navy).
abstract final class AppColors {
  // Brand core (from inventrax_icon.png)
  static const brandTeal = Color(0xFF1ABC9C);
  static const brandTealBright = Color(0xFF22D4B0);
  static const brandNavy = Color(0xFF051C33);
  static const brandNavyDeep = Color(0xFF061428);
  static const brandNavyMid = Color(0xFF0F2847);

  /// Structural brand color (sidebar, headers).
  static const primary = brandNavy;

  /// Lighter navy for gradients and chart fills.
  static const primaryLight = brandNavyMid;

  /// Primary action color (buttons, active nav, success).
  static const accent = brandTeal;
  static const accentMuted = Color(0xFFD8F5EE);
  static const accentMutedDark = Color(0xFF0D3D32);

  // Light surfaces
  static const bgLight = Color(0xFFF8FAFB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceMutedLight = Color(0xFFF0F4F8);
  static const inputFillLight = Color(0xFFF3F7FA);
  static const borderLight = Color(0xFFE2E8F0);
  static const textPrimaryLight = brandNavy;
  static const textSecondaryLight = Color(0xFF334155);
  static const textTertiaryLight = Color(0xFF64748B);

  // Dark surfaces (navy-based)
  static const bgDark = brandNavyDeep;
  static const surfaceDark = brandNavy;
  static const surfaceMutedDark = brandNavyMid;
  static const inputFillDark = Color(0xFF132A40);
  static const borderDark = Color(0xFF1E3A52);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFFCBD5E1);
  static const textTertiaryDark = Color(0xFF94A3B8);

  // Semantic
  static const success = brandTeal;
  static const successContainer = Color(0xFFD8F5EE);
  static const warning = Color(0xFFF59E0B);
  static const warningContainer = Color(0xFFFFF3CD);
  static const error = Color(0xFFE53935);
  static const errorContainer = Color(0xFFFEE2E2);
  static const info = Color(0xFF2563EB);
  static const infoContainer = Color(0xFFDBEAFE);

  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color scaffold(Brightness brightness) =>
      brightness == Brightness.dark ? bgDark : bgLight;

  static Color border(Brightness brightness) =>
      brightness == Brightness.dark ? borderDark : borderLight;

  static Color onSurfaceVariant(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  /// Teal tuned for the current brightness (slightly brighter on dark).
  static Color action(Brightness brightness) =>
      brightness == Brightness.dark ? brandTealBright : brandTeal;

  static Color onAction(Brightness brightness) =>
      brightness == Brightness.dark ? brandNavyDeep : Colors.white;

  static Color sidebarBackground(Brightness brightness) =>
      brightness == Brightness.dark ? brandNavyDeep : brandNavy;

  /// Money / price text — must stay readable on dark surfaces.
  static Color moneyText(Brightness brightness) =>
      brightness == Brightness.dark ? brandTealBright : brandNavy;

  /// Debt/payment status — brighter on dark backgrounds.
  static Color debtStatus(String status, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return switch (status) {
        'paid' => const Color(0xFF6EE7B7),
        'partially_paid' => const Color(0xFFFCD34D),
        'pending' => const Color(0xFF93C5FD),
        'active' || 'unpaid' => const Color(0xFFFCA5A5),
        'overdue' => const Color(0xFFF87171),
        'voided' => const Color(0xFFFCA5A5),
        _ => textSecondaryDark,
      };
    }
    return switch (status) {
      'paid' => const Color(0xFF2E7D32),
      'partially_paid' => const Color(0xFFEF6C00),
      'pending' => const Color(0xFF1565C0),
      'active' || 'unpaid' => const Color(0xFFC62828),
      'overdue' => const Color(0xFFB71C1C),
      'voided' => const Color(0xFFC62828),
      _ => const Color(0xFF546E7A),
    };
  }

}
