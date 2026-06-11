import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'sale_invoice_modal.dart';
import 'package:intl/intl.dart';

import '../../../../core/store_context.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/sales_search.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../../ui/components/app_skeleton.dart';

final _saleDetailProvider = FutureProvider.autoDispose
    .family<({Sale sale, List<SaleItem> items}), String>((ref, saleId) async {
  final db = ref.read(appDatabaseProvider);
  final sale = await db.getSaleById(storeId: StoreContext.storeId, saleId: saleId);
  if (sale == null) throw StateError('Sale not found');
  final items = await db.listSaleItems(storeId: StoreContext.storeId, saleId: saleId);
  return (sale: sale, items: items);
});

void showSaleDetailDrawer(BuildContext context, SaleListEntry entry) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: offset,
        child: Align(
          alignment: Alignment.centerRight,
          child: _SaleDetailPanel(entry: entry),
        ),
      );
    },
  );
}

class _SaleDetailPanel extends ConsumerWidget {
  const _SaleDetailPanel({required this.entry});

  final SaleListEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final panelWidth = width >= 900 ? 420.0 : width * 0.92;
    final detail = ref.watch(_saleDetailProvider(entry.sale.id));
    final currency = ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');

    return Material(
      elevation: 12,
      child: SizedBox(
        width: panelWidth,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Invoice ${entry.invoiceLabel}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: detail.when(
                loading: () => const ListPageSkeleton(itemCount: 4, showHeader: false),
                error: (e, _) => Center(child: Text('$e')),
                data: (bundle) {
                  final sale = bundle.sale;
                  final paymentLabel = _paymentLabel(sale.paymentJson);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _InfoRow('Date', dateFmt.format(sale.createdAt)),
                      _InfoRow('Customer', entry.customerName ?? 'Walk-in'),
                      _InfoRow('Status', sale.status),
                      _InfoRow('Payment', sale.paymentStatus),
                      _InfoRow('Method', paymentLabel),
                      const Divider(height: 24),
                      Text(
                        'Line items',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final item in bundle.items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.quantity} × ${formatMoney(item.unitPriceCents, currency: currency)}',
                          ),
                          trailing: Text(
                            formatMoney(item.lineTotalCents, currency: currency),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      const Divider(height: 24),
                      _InfoRow(
                        'Total',
                        formatMoney(sale.totalCents, currency: currency),
                        bold: true,
                      ),
                      if (sale.refundedTotalCents > 0)
                        _InfoRow(
                          'Refunded',
                          formatMoney(sale.refundedTotalCents, currency: currency),
                        ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showSaleInvoiceModal(context, ref, sale.id);
                        },
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('View A4 invoice'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          context.push('/sales/${sale.id}/receipt');
                        },
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Thermal receipt'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String paymentJson) {
    try {
      final m = jsonDecode(paymentJson);
      if (m is Map) {
        final name = m['paymentAccountName']?.toString();
        if (name != null && name.isNotEmpty) return name;
        final method = m['method']?.toString();
        if (method != null && method.isNotEmpty) return method;
      }
    } catch (_) {}
    return '—';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: bold
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      )
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
