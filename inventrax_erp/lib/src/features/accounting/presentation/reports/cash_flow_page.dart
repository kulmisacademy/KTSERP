import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/store_context.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../data/accounting_provider.dart';
import '../../domain/accounting_constants.dart';
import '../accounting_shell.dart';
import '../widgets/accounting_export_actions.dart';
import '../widgets/accounting_report_widgets.dart';
import '../widgets/accounting_ui.dart';

final cashFlowProvider =
    FutureProvider.autoDispose<List<AccountBalanceRow>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  return db.accountBalances(
    storeId: StoreContext.storeId,
    from: start,
    to: now,
  );
});

class CashFlowPage extends ConsumerWidget {
  const CashFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(storeCurrencyProvider);
    final data = ref.watch(cashFlowProvider);
    final period = DateFormat.yMMMM().format(DateTime.now());

    return AccountingShell(
      title: l10n.acctNavCashFlow,
      child: data.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (rows) {
          var operating = 0;
          var cashWallets = 0;
          final walletRows = <AccountBalanceRow>[];

          for (final r in rows) {
            final code = r.account.code;
            if (code == AcctCode.cash ||
                code == AcctCode.bank ||
                code == AcctCode.evcPlus ||
                code == AcctCode.zaad ||
                code == AcctCode.sahal) {
              cashWallets += r.balanceCents;
              operating += r.debitCents - r.creditCents;
              walletRows.add(r);
            }
          }

          return AccountingReportScaffold(
            title: l10n.acctNavCashFlow,
            subtitle: l10n.acctSimplifiedViewPeriod(period),
            exportFilename: 'cash_flow.pdf',
            buildPdf: (service) async {
              final pdfRows = await ref.read(cashFlowProvider.future);
              var pdfOperating = 0;
              var pdfCash = 0;
              final wallets = <({String name, int balanceCents})>[];
              for (final r in pdfRows) {
                final code = r.account.code;
                if (code == AcctCode.cash ||
                    code == AcctCode.bank ||
                    code == AcctCode.evcPlus ||
                    code == AcctCode.zaad ||
                    code == AcctCode.sahal) {
                  pdfCash += r.balanceCents;
                  pdfOperating += r.debitCents - r.creditCents;
                  wallets.add((name: r.account.name, balanceCents: r.balanceCents));
                }
              }
              final pdf = service.buildCashFlowPdf(
                storeName: accountingStoreLabel(ref),
                periodEnd: DateTime.now(),
                periodLabel: period,
                netMovement: pdfOperating,
                cashPosition: pdfCash,
                wallets: wallets,
                currency: ref.read(storeCurrencyProvider),
              );
              return pdf.save();
            },
            statusOk: operating >= 0,
            statusTitle: l10n.acctNetMovement,
            statusSubtitle:
                '${formatMoney(operating, currency: currency)} · ${l10n.acctCashPosition}: ${formatMoney(cashWallets, currency: currency)}',
            metrics: [
              AccountingReportMetric(
                label: l10n.acctNetMovement,
                value: formatMoney(operating, currency: currency),
                icon: Icons.swap_vert_rounded,
                color: operating >= 0
                    ? InventraXTheme.accent
                    : const Color(0xFFE53935),
              ),
              AccountingReportMetric(
                label: l10n.acctCashPosition,
                value: formatMoney(cashWallets, currency: currency),
                icon: Icons.account_balance_wallet_outlined,
                color: InventraXTheme.primary,
              ),
            ],
            children: [
              AccountingSectionTitle(
                label: l10n.acctOperatingActivities,
                count: walletRows.length,
                color: InventraXTheme.accent,
              ),
              AccountingSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net movement in cash wallets',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sales, purchases, and expenses through payment accounts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatMoney(operating, currency: currency),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: operating >= 0
                                      ? InventraXTheme.accent
                                      : const Color(0xFFE53935),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (walletRows.isNotEmpty) ...[
                      const Divider(height: 1),
                      for (var i = 0; i < walletRows.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(walletRows[i].account.name)),
                              Text(
                                formatMoney(
                                  walletRows[i].balanceCents,
                                  currency: currency,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AccountingSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financing & investing',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Owner deposits, withdrawals, and asset purchases are recorded in the general ledger. Use those screens for full detail.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.swap_vert, size: 18),
                          label: Text(l10n.acctNavDeposits),
                          onPressed: () => context.go('/accounting/cash'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.receipt_long, size: 18),
                          label: Text(l10n.acctNavGeneralLedger),
                          onPressed: () => context.go('/accounting/ledger'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
