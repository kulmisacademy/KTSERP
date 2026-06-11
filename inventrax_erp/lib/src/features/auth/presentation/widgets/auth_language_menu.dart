import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_locale.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../theme/kulmis_auth_theme.dart';

/// Compact language selector for auth form header.
class AuthLanguageMenu extends ConsumerWidget {
  const AuthLanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(appLocaleProvider);

    return PopupMenuButton<AppLocale>(
      tooltip: l10n.authLanguage,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (locale) => ref.read(appLocaleProvider.notifier).setLocale(locale),
      itemBuilder: (context) => [
        for (final locale in AppLocale.supported)
          PopupMenuItem(
            value: locale,
            child: Row(
              children: [
                if (current == locale)
                  const Icon(Icons.check, size: 18, color: KulmisAuthTheme.teal)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(_label(locale, l10n)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KulmisAuthTheme.borderLight),
          color: Colors.white,
          boxShadow: KulmisAuthTheme.inputShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: KulmisAuthTheme.textMuted),
            const SizedBox(width: 8),
            Text(
              _label(current, l10n),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KulmisAuthTheme.textDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: KulmisAuthTheme.textMuted),
          ],
        ),
      ),
    );
  }

  String _label(AppLocale locale, AppLocalizations l10n) => switch (locale) {
        AppLocale.english => l10n.languageEnglish,
        AppLocale.somali => l10n.languageSomali,
        AppLocale.arabic => l10n.languageArabic,
      };
}
