import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/store_settings_provider.dart';
import '../domain/invoice_branding.dart';

/// Single source of truth for invoice store branding — updates when settings stream changes.
final invoiceBrandingProvider = Provider<InvoiceBranding>((ref) {
  ref.watch(storeProfileProvider);
  final settings = ref.watch(storeSettingsProvider).value;
  return InvoiceBranding.fromSettings(settings);
});
