import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale.dart';
import 'l10n_extension.dart';
import 'locale_provider.dart';

/// Compact language control for the fixed sidebar footer.
class SidebarLocaleMenu extends ConsumerWidget {
  const SidebarLocaleMenu({
    super.key,
    this.collapsed = false,
    this.lightStyle = true,
  });

  final bool collapsed;
  final bool lightStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(appLocaleProvider);
    final fg = lightStyle ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant;
    final label = switch (current) {
      AppLocale.english => l10n.languageEnglish,
      AppLocale.somali => l10n.languageSomali,
      AppLocale.arabic => l10n.languageArabic,
    };

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        height: collapsed ? 32 : 30,
        child: PopupMenuButton<AppLocale>(
          tooltip: kIsWeb ? '' : l10n.languageTitle,
          offset: const Offset(0, -4),
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 30),
          onSelected: (locale) => ref.read(appLocaleProvider.notifier).setLocale(locale),
          itemBuilder: (_) => [
            for (final locale in AppLocale.supported)
              CheckedPopupMenuItem<AppLocale>(
                value: locale,
                checked: current == locale,
                child: Text(
                  _menuLabel(l10n, locale),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
          child: collapsed
              ? Icon(Icons.translate, color: fg, size: 16)
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Icon(Icons.translate, color: fg, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: fg,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.expand_more, color: fg, size: 14),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _menuLabel(dynamic l10n, AppLocale locale) => switch (locale) {
        AppLocale.english => l10n.languageEnglish,
        AppLocale.somali => l10n.languageSomali,
        AppLocale.arabic => l10n.languageArabic,
      };
}
