import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/design_system.dart';

/// Theme entry point — InventraX brand with full light/dark Material 3 coverage.
class InventraXTheme {
  static const primary = AppColors.primary;
  static const accent = AppColors.accent;
  static const warning = AppColors.warning;

  /// Price / money column text — readable in light and dark mode.
  static Color moneyText(Brightness brightness) => AppColors.moneyText(brightness);
  static const bgLight = AppColors.bgLight;
  static const cardLight = AppColors.surfaceLight;
  static const textDark = AppColors.textPrimaryLight;

  static const brandLogoAsset = BrandAssets.platformIcon;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static InventraXBrandTheme brand(Brightness brightness) =>
      brightness == Brightness.dark
          ? InventraXBrandTheme.dark
          : InventraXBrandTheme.light;

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? _darkScheme() : _lightScheme();
    final brandExt = brand(brightness);
    final action = AppColors.action(brightness);
    final onAction = AppColors.onAction(brightness);
    final textTheme = AppTypography.textTheme(brightness);
    final radius = AppRadius.mdAll;
    final buttonShape = RoundedRectangleBorder(borderRadius: radius);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [brandExt],
      scaffoldBackgroundColor: AppColors.scaffold(brightness),
      textTheme: textTheme,
      primaryColor: brandExt.navy,
      splashColor: action.withValues(alpha: 0.12),
      highlightColor: action.withValues(alpha: 0.08),
      hoverColor: action.withValues(alpha: 0.06),
      focusColor: action.withValues(alpha: 0.14),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.scaffold(brightness),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: AppColors.border(brightness)),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        backgroundColor: AppColors.surface(brightness),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface(brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.brandNavyMid : AppColors.brandNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: brandExt.teal,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: AppColors.border(brightness),
      ),
      iconTheme: IconThemeData(
        size: AppIcons.md,
        color: scheme.onSurfaceVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        contentPadding: AppSpacing.input,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border(brightness)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.border(brightness)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: action, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodySmall,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: onAction,
          disabledBackgroundColor: action.withValues(alpha: 0.35),
          disabledForegroundColor: onAction.withValues(alpha: 0.6),
          minimumSize: const Size(0, 44),
          padding: AppSpacing.button,
          shape: buttonShape,
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return onAction.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return onAction.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: action,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size(0, 44),
          padding: AppSpacing.button,
          shape: buttonShape,
          side: BorderSide(color: AppColors.border(brightness)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: action,
          minimumSize: const Size(0, 40),
          padding: AppSpacing.button,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: action,
          foregroundColor: onAction,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: AppSpacing.button,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          highlightColor: action.withValues(alpha: 0.12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: onAction,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return action.withValues(alpha: isDark ? 0.22 : 0.14);
            }
            return isDark ? AppColors.inputFillDark : AppColors.surfaceMutedLight;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return action;
            return scheme.onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: AppColors.border(brightness)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return action;
          return isDark ? AppColors.textTertiaryDark : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return action.withValues(alpha: 0.45);
          }
          return AppColors.border(brightness);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return action;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(onAction),
        side: BorderSide(color: AppColors.border(brightness), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return action;
          return AppColors.border(brightness);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: action,
        inactiveTrackColor: AppColors.border(brightness),
        thumbColor: action,
        overlayColor: action.withValues(alpha: 0.12),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: action,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: action,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border(brightness),
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface(brightness),
        indicatorColor: action.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? action : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? action : scheme.onSurfaceVariant,
            size: AppIcons.md,
          );
        }),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.surface(brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface(brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: textTheme.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface(brightness)),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface(brightness)),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minVerticalPadding: AppSpacing.xs,
        contentPadding: AppSpacing.listItem,
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        selectedColor: action,
        selectedTileColor: action.withValues(alpha: isDark ? 0.14 : 0.08),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 44,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        headingRowColor: WidgetStateProperty.all(
          isDark ? AppColors.inputFillDark : AppColors.surfaceMutedLight,
        ),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        dataTextStyle: textTheme.bodyMedium,
        dividerThickness: 1,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border(brightness)),
          borderRadius: AppRadius.lgAll,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.inputFillDark : AppColors.surfaceMutedLight,
        selectedColor: action.withValues(alpha: 0.18),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelSmall,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        side: BorderSide(color: AppColors.border(brightness)),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: action,
        textColor: onAction,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.brandNavyMid : AppColors.brandNavy,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: action,
        linearTrackColor: AppColors.border(brightness),
        circularTrackColor: AppColors.border(brightness),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          scheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(
          isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        side: WidgetStateProperty.all(
          BorderSide(color: AppColors.border(brightness)),
        ),
        textStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        hintStyle: WidgetStateProperty.all(textTheme.bodySmall),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface(brightness),
        selectedItemColor: action,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ColorScheme _lightScheme() => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.brandTeal,
        onPrimary: Colors.white,
        secondary: AppColors.brandNavy,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        primaryContainer: AppColors.accentMuted,
        onPrimaryContainer: AppColors.brandNavy,
        secondaryContainer: Color(0xFFE8EEF4),
        onSecondaryContainer: AppColors.brandNavy,
        surfaceContainerHighest: AppColors.surfaceMutedLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.borderLight,
        outlineVariant: AppColors.borderLight,
        shadow: Color(0x1A0D2137),
        scrim: Color(0x660D2137),
        inverseSurface: AppColors.brandNavy,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.brandTeal,
        tertiary: AppColors.textTertiaryLight,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accentMuted,
        onTertiaryContainer: AppColors.brandNavy,
      );

  static ColorScheme _darkScheme() => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.brandTealBright,
        onPrimary: AppColors.brandNavyDeep,
        secondary: AppColors.brandNavyMid,
        onSecondary: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        primaryContainer: AppColors.accentMutedDark,
        onPrimaryContainer: AppColors.brandTealBright,
        tertiaryContainer: AppColors.accentMutedDark,
        onTertiaryContainer: AppColors.brandTealBright,
        secondaryContainer: AppColors.brandNavyMid,
        onSecondaryContainer: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.brandNavyMid,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.borderDark,
        shadow: Color(0x80000000),
        scrim: Color(0xB3000000),
        inverseSurface: AppColors.textPrimaryDark,
        onInverseSurface: AppColors.brandNavyDeep,
        inversePrimary: AppColors.brandTeal,
        tertiary: AppColors.textTertiaryDark,
        onTertiary: AppColors.textPrimaryDark,
      );
}
