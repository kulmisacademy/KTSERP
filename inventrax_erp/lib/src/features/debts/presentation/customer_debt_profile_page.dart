import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/erp_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../data/debt_share_actions.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../data/debts_providers.dart';
import 'widgets/debt_payment_dialog.dart';
import 'widgets/debt_payment_timeline.dart';
import 'widgets/debt_ui.dart';

final customerDebtProfileProvider =
    StreamProvider.autoDispose.family<Customer?, String>((ref, customerId) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .watchCustomers(
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
      )
      .map((list) => list.where((c) => c.id == customerId).firstOrNull);
});

class CustomerDebtProfilePage extends ConsumerWidget {
  const CustomerDebtProfilePage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final customer = ref.watch(customerDebtProfileProvider(customerId));
    final debts = ref.watch(customerDebtsListProvider(customerId));
    return AppShell(
      title: 'Customer debt',
      actions: [
        IconButton(
          tooltip: 'Share',
          onPressed: () => _share(context, ref),
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          tooltip: 'Share on WhatsApp',
          onPressed: () => _sms(context, ref),
          icon: const Icon(Icons.chat_outlined),
        ),
      ],
      child: customer.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (c) {
          if (c == null) {
            return const Center(child: Text('Customer not found'));
          }
          final openDebts = debts.asData?.value ?? [];
          final totalRemaining = openDebts
              .where((d) => d.remainingCents > 0)
              .fold<int>(0, (s, d) => s + d.remainingCents);
          final totalPaid = openDebts.fold<int>(0, (s, d) => s + d.paidCents);

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
                        c.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (c.phone != null) Text(c.phone!),
                      if (c.address != null) Text(c.address!),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DebtKpiCard(
                              label: 'Remaining',
                              value: formatMoney(totalRemaining, currency: currency),
                              icon: Icons.account_balance_wallet,
                              color: debtStatusColor(
                                'active',
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DebtKpiCard(
                              label: 'Paid on record',
                              value: formatMoney(totalPaid, currency: currency),
                              icon: Icons.payments_outlined,
                              color: debtStatusColor(
                                'paid',
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _share(context, ref),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share link'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => _sms(context, ref),
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Share on WhatsApp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Invoices / debts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              debts.when(
                data: (rows) {
                  if (rows.isEmpty) {
                    return const Text('No debt records for this customer.');
                  }
                  return Column(
                    children: [
                      for (final d in rows) ...[
                        _DebtInvoiceCard(
                          debt: d,
                          currency: currency,
                          onPay: d.remainingCents > 0
                              ? () => _payDebt(context, ref, d, currency)
                              : null,
                          onViewSale: d.saleId != null
                              ? () => context.push('/sales/${d.saleId}/receipt')
                              : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment history',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              DebtPaymentTimeline(customerId: customerId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _payDebt(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
    String currency,
  ) async {
    final payment = await showDebtPaymentDialog(
      context,
      ref,
      maxCents: debt.remainingCents,
      currency: currency,
      title: 'Pay invoice ${debt.invoiceNumber ?? debt.id.substring(0, 8)}',
    );
    if (payment == null) return;
    await applyDebtPayment(
      ref: ref,
      context: context,
      debt: debt,
      payment: payment,
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final c = await ref.read(customerDebtProfileProvider(customerId).future);
    if (c == null) return;
    final debts = await ref.read(customerDebtsListProvider(customerId).future);
    final remaining = debts
        .where((d) => d.remainingCents > 0)
        .fold<int>(0, (s, d) => s + d.remainingCents);
    await shareCustomerDebt(
      ref: ref,
      customerId: customerId,
      customerName: c.name,
      balanceCents: remaining,
    );
  }

  Future<void> _sms(BuildContext context, WidgetRef ref) async {
    final c = await ref.read(customerDebtProfileProvider(customerId).future);
    if (c == null) return;
    final debts = await ref.read(customerDebtsListProvider(customerId).future);
    final openDebts = debts.where((d) => d.remainingCents > 0).toList();
    final remaining = openDebts.fold<int>(0, (s, d) => s + d.remainingCents);
    final focus = openDebts
            .where((d) => d.dueDate != null)
            .fold<Debt?>(
              null,
              (best, d) =>
                  best == null || d.dueDate!.isBefore(best.dueDate!) ? d : best,
            ) ??
        openDebts.firstOrNull;
    await sendCustomerDebtSms(
      context: context,
      ref: ref,
      customerId: customerId,
      customerName: c.name,
      phone: c.phone,
      balanceCents: remaining,
      debtId: focus?.id,
      dueDate: focus?.dueDate,
      invoiceNumber: focus?.invoiceNumber,
    );
  }
}

class _DebtInvoiceCard extends ConsumerWidget {
  const _DebtInvoiceCard({
    required this.debt,
    required this.currency,
    this.onPay,
    this.onViewSale,
  });

  final Debt debt;
  final String currency;
  final VoidCallback? onPay;
  final VoidCallback? onViewSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = debtStatusColor(debt.status, Theme.of(context).brightness);
    final saleItems = debt.saleId == null
        ? null
        : ref.watch(_saleItemsProvider(debt.saleId!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Invoice ${debt.invoiceNumber ?? debt.id.substring(0, 8)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(context.l10n.debtStatusLabel(debt.status)),
                  backgroundColor: color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: color, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              'Remaining ${formatMoney(debt.remainingCents, currency: currency)} • '
              'Paid ${formatMoney(debt.paidCents, currency: currency)}',
              style: theme.textTheme.bodySmall,
            ),
            if (saleItems != null)
              saleItems.when(
                data: (items) {
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final i in items)
                          Text(
                            '• ${i.name} × ${i.quantity} — '
                            '${formatMoney(i.lineTotalCents, currency: currency)}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (onViewSale != null)
                  TextButton(
                    onPressed: onViewSale,
                    child: const Text('Receipt'),
                  ),
                const Spacer(),
                if (onPay != null)
                  FilledButton.tonal(
                    onPressed: onPay,
                    child: const Text('Pay'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _saleItemsProvider = FutureProvider.autoDispose.family<List<SaleItem>, String>(
  (ref, saleId) {
    final db = ref.read(appDatabaseProvider);
    return db.listSaleItems(
      storeId: StoreContext.storeId,
      saleId: saleId,
    );
  },
);
