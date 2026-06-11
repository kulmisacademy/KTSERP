import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic text/surface helpers — use instead of hardcoded slate hex colors.
extension ThemeContrast on BuildContext {
  ThemeData get _theme => Theme.of(this);
  ColorScheme get _scheme => _theme.colorScheme;
  Brightness get _brightness => _theme.brightness;

  Color get mutedText => _scheme.onSurfaceVariant;
  Color get primaryText => _scheme.onSurface;
  Color get cardSurface => AppColors.surface(_brightness);
  Color get priceAccent => AppColors.action(_brightness);
  Color get brandAction => AppColors.action(_brightness);
  Color get successColor => AppColors.success;
  Color get errorColor => _scheme.error;
  Color get moneyText => AppColors.moneyText(_brightness);

  Color debtStatus(String status) => AppColors.debtStatus(status, _brightness);
}
