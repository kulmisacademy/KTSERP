import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/store/store_branding.dart';
import '../../core/money/currency_symbol.dart';
import '../../core/store_context.dart';
import '../../core/supabase_config.dart';
import '../../sync/supabase_bootstrap.dart';
import 'app_database.dart';
import 'db_provider.dart';

final storeSettingsRepositoryProvider = Provider<StoreSettingsRepository>((ref) {
  return StoreSettingsRepository(ref.watch(appDatabaseProvider));
});

/// Persists store branding locally first, then syncs to Supabase when possible.
class StoreSettingsRepository {
  StoreSettingsRepository(this._db);

  final AppDatabase _db;

  Future<StoreSetting> save(StoreSettingsCompanion companion) async {
    final storeId = companion.storeId.present
        ? companion.storeId.value
        : StoreContext.storeId;
    final tenantId = companion.tenantId.present
        ? companion.tenantId.value
        : StoreContext.tenantId;

    if (storeId.isEmpty) {
      throw StateError('No active store — cannot save settings');
    }

    final existing = await _db.getStoreSettings(storeId: storeId);
    if (existing == null) {
      await _db.upsertStoreSettings(
        StoreSettingsCompanion.insert(
          storeId: storeId,
          tenantId: tenantId,
          storeName: companion.storeName.present
              ? companion.storeName.value
              : _defaultStoreName(),
        ),
      );
    }

    final normalized = _normalizeCompanion(companion, storeId, tenantId);
    await _db.upsertStoreSettings(normalized);

    final saved = await _db.getStoreSettings(storeId: storeId);
    if (saved == null) {
      throw StateError('Store settings missing after save');
    }

    StoreBranding.applyToSession(saved);

    try {
      await _syncToCloud(saved);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Store settings cloud sync failed (local save OK): $e\n$st');
      }
      await _enqueueStoreUpdate(_cloudPayload(saved), saved.storeId);
    }

    return saved;
  }

  StoreSettingsCompanion _normalizeCompanion(
    StoreSettingsCompanion companion,
    String storeId,
    String tenantId,
  ) {
    String? optStr(Value<String?> field) {
      if (!field.present) return null;
      final raw = field.value;
      if (raw == null) return null;
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }

    String reqStr(Value<String> field, String fallback) {
      if (!field.present) return fallback;
      final t = field.value.trim();
      return t.isEmpty ? fallback : t;
    }

    return StoreSettingsCompanion(
      storeId: Value(storeId),
      tenantId: Value(tenantId),
      storeName: companion.storeName.present
          ? Value(reqStr(companion.storeName, _defaultStoreName()))
          : const Value.absent(),
      businessType: companion.businessType,
      phone: companion.phone.present
          ? Value(optStr(companion.phone))
          : const Value.absent(),
      address: companion.address.present
          ? Value(optStr(companion.address))
          : const Value.absent(),
      email: companion.email.present
          ? Value(optStr(companion.email))
          : const Value.absent(),
      taxNumber: companion.taxNumber.present
          ? Value(optStr(companion.taxNumber))
          : const Value.absent(),
      currencyCode: companion.currencyCode,
      currencySymbol: companion.currencySymbol.present
          ? companion.currencySymbol
          : companion.currencyCode.present
              ? Value(currencySymbolFor(companion.currencyCode.value))
              : const Value.absent(),
      country: companion.country,
      localeCode: companion.localeCode,
      taxRateBps: companion.taxRateBps,
      taxName: companion.taxName,
      taxInclusive: companion.taxInclusive,
      receiptHeader: companion.receiptHeader.present
          ? Value(optStr(companion.receiptHeader))
          : const Value.absent(),
      invoiceFooter: companion.invoiceFooter.present
          ? Value(optStr(companion.invoiceFooter))
          : const Value.absent(),
      logoUrl: companion.logoUrl,
      logoLocalPath: companion.logoLocalPath,
      allowCashierPriceOverride: companion.allowCashierPriceOverride,
      autoPrintReceipt: companion.autoPrintReceipt,
      invoiceShowSku: companion.invoiceShowSku,
      invoiceShowDiscount: companion.invoiceShowDiscount,
      invoiceShowTax: companion.invoiceShowTax,
      invoiceCompactMode: companion.invoiceCompactMode,
      planName: companion.planName,
      updatedAt: companion.updatedAt.present
          ? companion.updatedAt
          : Value(DateTime.now()),
    );
  }

  Future<void> _syncToCloud(StoreSetting settings) async {
    final payload = _cloudPayload(settings);
    final client = supabaseClient;

    if (client == null || !SupabaseConfig.isConfigured) {
      await _enqueueStoreUpdate(payload, settings.storeId);
      return;
    }

    await client
        .from('stores')
        .update(payload)
        .eq('id', settings.storeId)
        .eq('tenant_id', settings.tenantId);
  }

  Map<String, dynamic> _cloudPayload(StoreSetting s) => {
        'name': s.storeName,
        'phone': s.phone,
        'email': s.email,
        'address': s.address,
        'invoice_footer': s.invoiceFooter,
        'logo_url': s.logoUrl,
        'tax_number': s.taxNumber,
        'currency_code': s.currencyCode,
        'country': s.country,
        'locale_code': s.localeCode,
      };

  static String _defaultStoreName() {
    final ctx = StoreContext.storeName?.trim();
    if (ctx != null && ctx.isNotEmpty && ctx != 'My Store') return ctx;
    return 'My Store';
  }

  Future<void> _enqueueStoreUpdate(
    Map<String, dynamic> payload,
    String storeId,
  ) async {
    await _db.enqueueSync(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      entity: 'stores',
      entityId: storeId,
      operation: 'upsert',
      payload: payload,
    );
  }
}
