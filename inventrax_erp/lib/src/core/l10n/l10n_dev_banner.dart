import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_locale.dart';
import 'l10n_extension.dart';
import 'locale_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug-only banner when locale is not English (reminder to check ARB parity).
class L10nDevBanner extends ConsumerWidget {
  const L10nDevBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return child;

    final locale = ref.watch(appLocaleProvider);
    if (locale == AppLocale.english) return child;

    return Banner(
      message: locale.code.toUpperCase(),
      location: BannerLocation.topEnd,
      color: Colors.orange.shade800,
      child: child,
    );
  }
}

/// Shows a one-time snackbar hint after switching away from English (debug only).
void maybeShowL10nDevHint(BuildContext context, AppLocale locale) {
  if (!kDebugMode || locale == AppLocale.english) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.l10nDevMissingBanner(locale.aiLanguageName)),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}
