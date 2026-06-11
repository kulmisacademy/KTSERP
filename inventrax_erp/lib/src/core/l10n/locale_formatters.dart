import 'package:intl/intl.dart';

import 'app_locale.dart';

/// Locale-aware date/number helpers (currency symbols stay store-driven).
class LocaleFormatters {
  LocaleFormatters(this.locale);

  final AppLocale locale;

  String formatDate(DateTime dt, {String pattern = 'yMMMd'}) {
    return DateFormat(pattern, locale.code).format(dt);
  }

  String formatDateTime(DateTime dt) {
    return DateFormat.yMMMd(locale.code).add_jm().format(dt);
  }

  String formatNumber(num value, {int? decimals}) {
    final f = NumberFormat.decimalPattern(locale.code);
    if (decimals != null) f.minimumFractionDigits = decimals;
    if (decimals != null) f.maximumFractionDigits = decimals;
    return f.format(value);
  }

  String formatCents(int cents, {required String currencyCode}) {
    final amount = cents / 100;
    final symbol = _currencySymbol(currencyCode);
    final formatted = formatNumber(amount, decimals: 2);
    if (locale.isRtl) {
      return '$formatted $symbol';
    }
    return '$symbol$formatted';
  }

  static String _currencySymbol(String currency) => switch (currency) {
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        'KES' => 'KSh ',
        'SOS' => 'Sh ',
        _ => '$currency ',
      };
}
