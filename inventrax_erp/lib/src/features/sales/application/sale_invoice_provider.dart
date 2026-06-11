import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store/store_branding.dart';
import '../../../core/store/active_store_scope.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../domain/sale_invoice_data.dart';
import 'invoice_branding_provider.dart';

/// Sale line items + totals for invoice preview (branding comes from [invoiceBrandingProvider]).
final saleInvoiceProvider = FutureProvider.autoDispose
    .family<SaleInvoiceData, String>((ref, saleId) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.read(appDatabaseProvider);
  ref.watch(invoiceBrandingProvider);
  final settings = await ref.watch(storeSettingsProvider.future);
  final storeId = scope.storeId;

  final sale = await db.getSaleById(storeId: storeId, saleId: saleId);
  if (sale == null) throw StateError('Sale not found');

  final items = await db.listSaleItems(storeId: storeId, saleId: saleId);

  Customer? customer;
  if (sale.customerId != null) {
    customer = await db.getCustomerById(
      storeId: storeId,
      customerId: sale.customerId!,
    );
  }

  return SaleInvoiceData.fromSale(
    sale: sale,
    items: items,
    settings: settings,
    customer: customer,
    paymentMethod: _paymentLabel(sale.paymentJson),
    logoRemoteUrl: StoreBranding.logoUrlWithCacheBust(settings),
  );
});

String _paymentLabel(String paymentJson) {
  try {
    final m = jsonDecode(paymentJson);
    if (m is Map) {
      final name = m['paymentAccountName']?.toString();
      if (name != null && name.isNotEmpty) return name;
      final method = m['method']?.toString();
      if (method == 'split') return 'Split payment';
      if (method != null && method.isNotEmpty) return method;
    }
  } catch (_) {}
  return '—';
}
