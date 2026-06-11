import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../app/app_theme.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/sales_search.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../accounting/data/accounting_provider.dart';
import '../../dashboard/dashboard_providers.dart';
import '../../pos/domain/pos_models.dart';
import '../../pos/domain/pos_state.dart';
import '../../pos/presentation/pos_receipt.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/layout/app_shell.dart';
import 'sales_history_provider.dart';
import 'widgets/sales_virtual_table.dart';

String _paymentSummaryFromPaymentJson(
  String paymentJson,
  AppLocalizations l10n,
) {
  try {
    final m = jsonDecode(paymentJson);
    if (m is Map) {
      final accountName = m['paymentAccountName']?.toString();
      if (accountName != null && accountName.trim().isNotEmpty) {
        return accountName.trim();
      }
      final method = m['method']?.toString();
      if (method == 'split') return l10n.splitPayment;
      if (method != null && method.trim().isNotEmpty) return method.trim();
    }
  } catch (_) {}
  return l10n.paymentLabel;
}

class SalesHistoryPage extends ConsumerStatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  ConsumerState<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends ConsumerState<SalesHistoryPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _patchQuery(SalesHistoryQuery Function(SalesHistoryQuery) fn) {
    ref.read(salesHistoryQueryProvider.notifier).patch(
          fn(ref.read(salesHistoryQueryProvider)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(salesCatalogProvider);
    final summary = ref.watch(salesHistorySummaryProvider);
    final pendingSync = ref.watch(salesHistoryPendingSyncProvider);
    final query = ref.watch(salesHistoryQueryProvider);
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';

    final l10n = context.l10n;

    return AppShell(
      route: '/sales',
      subtitle: _rangeLabel(l10n, query),
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.go('/pos'),
          icon: const Icon(Icons.point_of_sale_outlined, size: 18),
          label: Text(l10n.openPos),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          summary.when(
            data: (s) => _MetricsStrip(
              summary: s,
              pendingSync: pendingSync,
              currency: currency,
              l10n: l10n,
            ),
            loading: () => const SkeletonBox(
              width: double.infinity,
              height: 72,
              borderRadius: 14,
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.salesSearchHint,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => _patchQuery((q) => q.copyWith(search: v)),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final preset in SalesDatePreset.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_datePresetLabel(l10n, preset)),
                      selected: query.datePreset == preset,
                      onSelected: (_) => _patchQuery(
                        (q) => q.copyWith(datePreset: preset),
                      ),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in SalesPaymentFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_paymentFilterLabel(l10n, f)),
                      selected: query.paymentFilter == f,
                      onSelected: (_) => _patchQuery(
                        (q) => q.copyWith(paymentFilter: f),
                      ),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: catalog.when(
              data: (state) {
                if (state.items.isEmpty) {
                  return AppEmptyState(
                    title: l10n.noMatchingSales,
                    subtitle: l10n.noMatchingSalesSubtitle,
                    icon: Icons.receipt_long_outlined,
                    action: AppButton(
                      label: l10n.openPos,
                      icon: Icons.point_of_sale_outlined,
                      onPressed: () => context.go('/pos'),
                    ),
                  );
                }
                return SalesVirtualTable(
                  items: state.items,
                  currency: currency,
                  hasMore: state.hasMore,
                  isLoadingMore: state.isLoadingMore,
                  onLoadMore: () =>
                      ref.read(salesCatalogProvider.notifier).loadMore(),
                  onReprint: (e) =>
                      _reprintReceipt(context, ref, e.sale),
                  onVoid: (e) => _voidSale(context, ref, e.sale),
                  onRefund: (e) => _partialRefund(context, ref, e.sale),
                );
              },
              loading: () => const ListPageSkeleton(),
              error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(AppLocalizations l10n, SalesHistoryQuery q) =>
      switch (q.datePreset) {
        SalesDatePreset.today => l10n.salesRangeToday,
        SalesDatePreset.week => l10n.salesRangeWeek,
        SalesDatePreset.month => l10n.salesRangeMonth,
        SalesDatePreset.custom => l10n.salesRangeCustom,
      };

  String _datePresetLabel(AppLocalizations l10n, SalesDatePreset p) =>
      switch (p) {
        SalesDatePreset.today => l10n.filterToday,
        SalesDatePreset.week => l10n.filterWeek,
        SalesDatePreset.month => l10n.filterMonth,
        SalesDatePreset.custom => l10n.filterCustom,
      };

  String _paymentFilterLabel(AppLocalizations l10n, SalesPaymentFilter f) =>
      switch (f) {
        SalesPaymentFilter.all => l10n.filterAll,
        SalesPaymentFilter.paid => l10n.statusPaid,
        SalesPaymentFilter.partial => l10n.statusPartial,
        SalesPaymentFilter.unpaid => l10n.statusUnpaid,
        SalesPaymentFilter.refunded => l10n.statusRefunded,
        SalesPaymentFilter.voided => l10n.statusVoided,
      };

  static Future<void> _voidSale(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final l10n = context.l10n;
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.voidSaleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.voidSaleBody,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              decoration: InputDecoration(labelText: l10n.reason),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.voidAction),
          ),
        ],
      ),
    );
    final reasonText = reason.text.trim();
    reason.dispose();
    if (ok != true) return;

    await ref.read(appDatabaseProvider).voidSale(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          saleId: sale.id,
          reason: reasonText.isEmpty ? 'Voided' : reasonText,
          userId: StoreContext.userId,
        );

    final voided = await ref.read(appDatabaseProvider).getSaleById(
          storeId: StoreContext.storeId,
          saleId: sale.id,
        );
    if (voided != null) {
      try {
        await ref.read(accountingEngineProvider).postVoidSale(sale: voided);
      } catch (_) {}
    }

    ref.invalidate(salesCatalogProvider);
    ref.invalidate(salesHistorySummaryProvider);
    invalidateDashboardMetrics(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saleVoidedSnack)),
      );
    }
  }

  static Future<void> _partialRefund(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final db = ref.read(appDatabaseProvider);
    final items = await db.listSaleItems(
      storeId: StoreContext.storeId,
      saleId: sale.id,
    );
    final qtyControllers = <String, TextEditingController>{};
    for (final item in items) {
      final remaining = item.quantity - item.refundedQuantity;
      if (remaining <= 0) continue;
      qtyControllers[item.id] = TextEditingController(text: '0');
    }
    final l10n = context.l10n;
    if (qtyControllers.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nothingToRefund)),
        );
      }
      return;
    }

    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.partialRefundTitle),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...items.where((i) => qtyControllers.containsKey(i.id)).map(
                  (i) {
                    final remaining = i.quantity - i.refundedQuantity;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('${i.name} (max $remaining)')),
                          SizedBox(
                            width: 72,
                            child: TextField(
                              controller: qtyControllers[i.id],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: l10n.qty),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                TextField(
                  controller: reason,
                  decoration: InputDecoration(labelText: l10n.reason),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.refundAction)),
        ],
      ),
    );

    final lineRefunds = <String, int>{};
    for (final e in qtyControllers.entries) {
      final q = int.tryParse(e.value.text.trim()) ?? 0;
      if (q > 0) lineRefunds[e.key] = q;
    }
    for (final c in qtyControllers.values) {
      c.dispose();
    }
    final reasonText = reason.text.trim();
    reason.dispose();
    if (ok != true || lineRefunds.isEmpty) return;

    final cents = await db.partialRefundSale(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      saleId: sale.id,
      lineRefunds: lineRefunds,
      reason: reasonText.isEmpty ? 'Refund' : reasonText,
      userId: StoreContext.userId,
    );

    ref.invalidate(salesCatalogProvider);
    ref.invalidate(salesHistorySummaryProvider);
    invalidateDashboardMetrics(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cents > 0
                ? l10n.refundedAmountSnack((cents / 100).toStringAsFixed(2))
                : l10n.noItemsRefunded,
          ),
        ),
      );
    }
  }

  static Future<void> _reprintReceipt(
    BuildContext context,
    WidgetRef ref,
    Sale sale,
  ) async {
    final db = ref.read(appDatabaseProvider);
    final items = await db.listSaleItems(
      storeId: StoreContext.storeId,
      saleId: sale.id,
    );
    final cart = items
        .map(
          (i) => PosCartItem(
            productId: i.productId ?? i.id,
            name: i.name,
            barcode: i.barcode,
            unitPriceCents: i.unitPriceCents,
            unitCostCents: i.unitCostCents,
            catalogPriceCents: i.unitPriceCents,
            quantity: i.quantity,
            isDirectSale: i.productId == null,
          ),
        )
        .toList();

    final snapshot = PosState(
      cart: cart,
      orderDiscountCents: sale.discountCents,
      taxCents: sale.taxCents,
      customerId: sale.customerId,
      customerName: null,
      notes: sale.notes,
    );

    final settings = ref.read(storeSettingsProvider).value;
    await printSaleReceipt(
      settings: settings,
      cartState: snapshot,
      paymentSummary: _paymentSummaryFromPaymentJson(
        sale.paymentJson,
        context.l10n,
      ),
      saleId: sale.id,
    );
  }
}

extension on SalesHistoryQuery {
  SalesHistoryQuery copyWith({
    String? search,
    SalesPaymentFilter? paymentFilter,
    SalesDatePreset? datePreset,
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    return SalesHistoryQuery(
      search: search ?? this.search,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      datePreset: datePreset ?? this.datePreset,
      customFrom: customFrom ?? this.customFrom,
      customTo: customTo ?? this.customTo,
    );
  }
}

class _MetricsStrip extends StatelessWidget {
  const _MetricsStrip({
    required this.summary,
    required this.pendingSync,
    required this.currency,
    required this.l10n,
  });

  final SalesHistorySummary summary;
  final int pendingSync;
  final String currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.today_outlined,
            label: l10n.netRevenue,
            value: formatMoney(summary.netRevenueCents, currency: currency),
            color: InventraXTheme.accent,
            compactValue: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.receipt_long_outlined,
            label: l10n.transactions,
            value: '${summary.transactionCount}',
            color: AppColors.moneyText(brightness),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.pending_actions_outlined,
            label: l10n.unpaidCount,
            value: '${summary.unpaidCount}',
            color: InventraXTheme.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.cloud_queue_outlined,
            label: l10n.metricSyncQueue,
            value: '$pendingSync',
            color: pendingSync > 0 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compactValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: (compactValue
                          ? Theme.of(context).textTheme.titleSmall
                          : Theme.of(context).textTheme.titleMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
