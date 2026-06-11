import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/erp_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../data/debt_share_actions.dart';
import 'widgets/debt_payment_dialog.dart';
import 'widgets/debt_ui.dart';

final supplierDebtProfileProvider =
    FutureProvider.autoDispose.family<Supplier?, String>((ref, supplierId) {
  final db = ref.read(appDatabaseProvider);
  return db.getSupplierById(supplierId);
});

final supplierDebtsListProvider =
    StreamProvider.autoDispose.family<List<Debt>, String>((ref, supplierId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchDebtsForSupplier(
    storeId: StoreContext.storeId,
    supplierId: supplierId,
  );
});

class SupplierDebtProfilePage extends ConsumerWidget {
  const SupplierDebtProfilePage({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final supplier = ref.watch(supplierDebtProfileProvider(supplierId));
    final debts = ref.watch(supplierDebtsListProvider(supplierId));

    return AppShell(
      title: 'Supplier payable',
      actions: [
        IconButton(
          tooltip: 'Share',
          onPressed: () => _onShare(context, ref, currency),
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          tooltip: 'Share on WhatsApp',
          onPressed: () => _onSms(context, ref, currency),
          icon: const Icon(Icons.sms_outlined),
        ),
      ],
      child: supplier.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) {
          if (s == null) {
            return const Center(child: Text('Supplier not found'));
          }
          return debts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (rows) {
              final remaining = rows
                  .where((d) => d.remainingCents > 0)
                  .fold<int>(0, (sum, d) => sum + d.remainingCents);
              final paid = rows.fold<int>(0, (sum, d) => sum + d.paidCents);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  child: Icon(Icons.local_shipping,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      if (s.phone != null) Text(s.phone!),
                                      if (s.address != null) Text(s.address!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DebtKpiCard(
                                    label: 'Payable',
                                    value: formatMoney(remaining,
                                        currency: currency),
                                    icon: Icons.arrow_upward,
                                    color: debtStatusColor(
                                      'active',
                                      Theme.of(context).brightness,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DebtKpiCard(
                                    label: 'Paid',
                                    value: formatMoney(paid,
                                        currency: currency),
                                    icon: Icons.check_circle_outline,
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
                                  onPressed: () =>
                                      _onShare(context, ref, currency),
                                  icon: const Icon(Icons.share_outlined),
                                  label: const Text('Share'),
                                ),
                                FilledButton.tonalIcon(
                                  onPressed: () =>
                                      _onSms(context, ref, currency),
                                  icon: const Icon(Icons.sms_outlined),
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
                      'Purchase debts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (rows.isEmpty)
                      const Text('No payable records for this supplier.')
                    else
                      ...rows.map((d) {
                        final color = debtStatusColor(
                          d.status,
                          Theme.of(context).brightness,
                        );
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              'Invoice ${d.invoiceNumber ?? d.id.substring(0, 8)}',
                            ),
                            subtitle: Text(
                              '${context.l10n.debtStatusLabel(d.status)} • '
                              'Due ${formatMoney(d.remainingCents, currency: currency)}',
                            ),
                            trailing: d.remainingCents > 0
                                ? FilledButton.tonal(
                                    onPressed: () =>
                                        _pay(context, ref, d, currency),
                                    child: const Text('Pay'),
                                  )
                                : Icon(Icons.check_circle, color: color),
                            onTap: d.purchaseId != null
                                ? () => context.push(
                                      '/purchases/${d.purchaseId}',
                                    )
                                : null,
                          ),
                        );
                      }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onShare(
    BuildContext context,
    WidgetRef ref,
    String currency,
  ) async {
    final s = await ref.read(supplierDebtProfileProvider(supplierId).future);
    if (s == null) return;
    final debts = await ref.read(supplierDebtsListProvider(supplierId).future);
    final remaining = debts
        .where((d) => d.remainingCents > 0)
        .fold<int>(0, (sum, d) => sum + d.remainingCents);
    await shareSupplierPayable(
      ref: ref,
      supplierName: s.name,
      balanceCents: remaining,
    );
  }

  Future<void> _onSms(
    BuildContext context,
    WidgetRef ref,
    String currency,
  ) async {
    final s = await ref.read(supplierDebtProfileProvider(supplierId).future);
    if (s == null) return;
    final debts = await ref.read(supplierDebtsListProvider(supplierId).future);
    final remaining = debts
        .where((d) => d.remainingCents > 0)
        .fold<int>(0, (sum, d) => sum + d.remainingCents);
    await sendSupplierPayableSms(
      context: context,
      ref: ref,
      supplierName: s.name,
      phone: s.phone,
      balanceCents: remaining,
    );
  }

  Future<void> _pay(
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
      title: 'Pay supplier',
    );
    if (payment == null) return;
    await applyDebtPayment(
      ref: ref,
      context: context,
      debt: debt,
      payment: payment,
    );
    ref.invalidate(supplierDebtsListProvider(supplierId));
  }
}
