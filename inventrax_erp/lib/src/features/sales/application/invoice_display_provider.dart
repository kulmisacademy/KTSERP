import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/store_settings_provider.dart';
import '../domain/invoice_display_preferences.dart';

/// Store-wide default invoice display preferences from settings.
final storeInvoiceDisplayProvider = Provider<InvoiceDisplayPreferences>((ref) {
  final settings = ref.watch(storeSettingsProvider).value;
  return InvoiceDisplayPreferences.fromStore(settings);
});

/// Per-preview session overrides keyed by sale id or preview session id.
final invoiceDisplayOverridesProvider =
    NotifierProvider<InvoiceDisplayOverrides, Map<String, InvoiceDisplayPreferences>>(
  InvoiceDisplayOverrides.new,
);

class InvoiceDisplayOverrides extends Notifier<Map<String, InvoiceDisplayPreferences>> {
  @override
  Map<String, InvoiceDisplayPreferences> build() => {};

  void setOverride(String sessionKey, InvoiceDisplayPreferences prefs) {
    state = {...state, sessionKey: prefs};
  }

  void clearOverride(String sessionKey) {
    if (!state.containsKey(sessionKey)) return;
    final next = Map<String, InvoiceDisplayPreferences>.from(state);
    next.remove(sessionKey);
    state = next;
  }
}

/// Effective display for a preview session (override wins over draft/store defaults).
InvoiceDisplayPreferences effectiveInvoiceDisplay(
  WidgetRef ref,
  String sessionKey, {
  InvoiceDisplayPreferences? draftPrefs,
}) {
  final override = ref.watch(invoiceDisplayOverridesProvider)[sessionKey];
  if (override != null) return override;
  if (draftPrefs != null) return draftPrefs;
  return ref.watch(storeInvoiceDisplayProvider);
}
