import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/currency_symbol.dart';
import '../../core/store/active_store_scope.dart';
import '../../core/store/store_branding.dart';
import '../../core/store_context.dart';
import '../../features/pos/domain/pos_tax.dart';
import 'app_database.dart';
import 'db_provider.dart';

/// Global store profile for sidebar, dashboard, invoices, receipts, and exports.
class StoreProfile {
  const StoreProfile({
    required this.displayName,
    this.phone,
    this.email,
    this.address,
    this.taxNumber,
    this.logoLocalPath,
    this.logoUrl,
    this.currencyCode = 'USD',
    this.updatedAt,
  });

  final String displayName;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxNumber;
  final String? logoLocalPath;
  final String? logoUrl;
  final String currencyCode;
  final DateTime? updatedAt;

  factory StoreProfile.fromSettings(StoreSetting? settings) {
    return StoreProfile(
      displayName: StoreBranding.displayName(settings),
      phone: _trimOrNull(settings?.phone),
      email: _trimOrNull(settings?.email),
      address: _trimOrNull(settings?.address),
      taxNumber: _trimOrNull(settings?.taxNumber),
      logoLocalPath: _trimOrNull(settings?.logoLocalPath),
      logoUrl: StoreBranding.logoUrlWithCacheBust(settings),
      currencyCode: settings?.currencyCode ?? 'USD',
      updatedAt: settings?.updatedAt,
    );
  }

  static String? _trimOrNull(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}

final posTaxProvider = Provider<PosTaxCalculator>((ref) {
  final settings = ref.watch(storeSettingsProvider).value;
  return PosTaxCalculator(
    taxRateBps: settings?.taxRateBps,
    taxInclusive: settings?.taxInclusive ?? false,
    taxName: settings?.taxName,
  );
});

/// Global store settings stream — keepAlive so branding propagates app-wide.
final storeSettingsProvider = StreamProvider<StoreSetting?>((ref) {
  ref.keepAlive();
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.watchStoreSettings(storeId: scope.storeId);
});

final storeCurrencyProvider = Provider<String>((ref) {
  return ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
});

/// Unified company profile — propagates branding app-wide when settings stream updates.
final storeProfileProvider = Provider<StoreProfile>((ref) {
  final settings = ref.watch(storeSettingsProvider).value;
  return StoreProfile.fromSettings(settings);
});

/// Resolved display name — updates when settings stream changes.
final storeDisplayNameProvider = Provider<String>((ref) {
  return ref.watch(storeProfileProvider).displayName;
});

/// Cache-busted logo URL for network image widgets.
final storeLogoUrlProvider = Provider<String?>((ref) {
  return ref.watch(storeProfileProvider).logoUrl;
});

String formatMoney(int cents, {String currency = 'USD'}) {
  final symbol = currencySymbolFor(currency);
  return '$symbol${(cents / 100).toStringAsFixed(2)}';
}
