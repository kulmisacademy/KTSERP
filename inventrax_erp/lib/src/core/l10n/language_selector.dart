import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale.dart';
import 'l10n_extension.dart';
import 'locale_provider.dart';

/// Settings language picker with native names and flag-style icons.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(appLocaleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.languageTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final locale in AppLocale.supported)
          _LanguageTile(
            locale: locale,
            selected: current == locale,
            onTap: () => ref.read(appLocaleProvider.notifier).setLocale(locale),
          ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final AppLocale locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, title, subtitle) = switch (locale) {
      AppLocale.english => (
          Icons.language,
          l10n.languageEnglish,
          l10n.languageEnglishNative,
        ),
      AppLocale.somali => (
          Icons.flag_outlined,
          l10n.languageSomali,
          l10n.languageSomaliNative,
        ),
      AppLocale.arabic => (
          Icons.translate,
          l10n.languageArabic,
          l10n.languageArabicNative,
        ),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selected: selected,
      onTap: onTap,
    );
  }
}
