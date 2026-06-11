import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/layout/app_shell.dart';

class PurchaseDetailData {
  const PurchaseDetailData({
    required this.purchase,
    required this.items,
    required this.supplierName,
    required this.lineLabels,
  });

  final Purchase purchase;
  final List<PurchaseItem> items;
  final String supplierName;
  final Map<String, String> lineLabels;
}

final purchaseDetailProvider =
    FutureProvider.autoDispose.family<PurchaseDetailData?, String>((ref, purchaseId) async {
  final db = ref.read(appDatabaseProvider);
  final storeId = StoreContext.storeId;
  final purchase = await db.getPurchaseById(
    storeId: storeId,
    purchaseId: purchaseId,
  );
  if (purchase == null) return null;

  final items = await db.listPurchaseItemsForPurchase(
    storeId: storeId,
    purchaseId: purchaseId,
  );
  final supplier = await db.getSupplierById(purchase.supplierId);
  final labels = <String, String>{};
  for (final item in items) {
    final product = await db.getProductById(
      storeId: storeId,
      productId: item.productId,
    );
    labels[item.id] = product?.name ?? item.productId;
  }

  return PurchaseDetailData(
    purchase: purchase,
    items: items,
    supplierName: supplier?.name ?? '',
    lineLabels: labels,
  );
});

class PurchaseDetailPage extends ConsumerWidget {
  const PurchaseDetailPage({super.key, required this.purchaseId});

  final String purchaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(purchaseDetailProvider(purchaseId));
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final dateFmt = DateFormat.yMMMd().add_jm();

    return AppShell(
      title: l10n.purchaseDetailTitle,
      child: detail.when(
        data: (data) {
          if (data == null) {
            return Center(child: Text(l10n.purchaseNotFound));
          }
          final supplierName = data.supplierName.isEmpty
              ? l10n.unknownSupplier
              : data.supplierName;
          final p = data.purchase;
          final remaining = p.totalCents - p.paidCents;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplierName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(dateFmt.format(p.purchaseDate)),
                      if (p.invoiceNumber != null && p.invoiceNumber!.isNotEmpty)
                        Text(l10n.purchaseInvoiceLine(p.invoiceNumber!)),
                      const Divider(height: 24),
                      _row(l10n.commonTotal, formatMoney(p.totalCents, currency: currency)),
                      _row(l10n.purchasePaid, formatMoney(p.paidCents, currency: currency)),
                      _row(
                        l10n.colStatus,
                        p.paymentStatus.replaceAll('_', ' ').toUpperCase(),
                      ),
                      if (remaining > 0)
                        _row(
                          l10n.purchaseOutstanding,
                          formatMoney(remaining, currency: currency),
                          emphasize: true,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.lineItems, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...data.items.map((item) {
                final name = data.lineLabels[item.id] ?? item.productId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                      '${item.quantity} × ${formatMoney(item.purchasePriceCents, currency: currency)}',
                    ),
                    trailing: Text(
                      formatMoney(item.lineTotalCents, currency: currency),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
