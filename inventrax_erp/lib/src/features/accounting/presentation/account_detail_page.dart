import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app/app_theme.dart';
import '../../../core/design/app_charts.dart';
import '../../../core/l10n/acct_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import '../domain/accounting_constants.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class AccountDetailPage extends ConsumerWidget {
  const AccountDetailPage({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(storeCurrencyProvider);
    final detail = ref.watch(accountDetailProvider(accountId));
    final ledger = ref.watch(accountLedgerProvider(accountId));
    final monthly = ref.watch(accountMonthlyActivityProvider(accountId));
    final dateFmt = DateFormat('MMM d, yyyy');

    return AccountingShell(
      title: l10n.acctNavChartOfAccounts,
      child: detail.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (row) {
          if (row == null) {
            return AccountingEmptyState(
              title: l10n.acctAccountNotFound,
              subtitle: l10n.acctNavChartOfAccounts,
              icon: Icons.search_off_outlined,
            );
          }
          final account = row.account;
          final canDelete = account.isActive &&
              row.balanceCents == 0 &&
              row.debitCents == 0 &&
              row.creditCents == 0;

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: '${account.code} • ${account.name}',
                  subtitle: localizedAccountTypeLabel(l10n, account.type),
                  trailing: IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                AccountingSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accountTypeColor(account.type)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: accountTypeColor(account.type),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.acctCurrentBalance,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              formatMoney(row.balanceCents, currency: currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      if (account.isSystem)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.acctSystemBadge,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AccountingSectionTitle(
                  label: l10n.acctActivityLast6Months,
                  count: 6,
                  color: accountTypeColor(account.type),
                ),
                AccountingSurfaceCard(
                  child: monthly.when(
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => SizedBox(
                      height: 120,
                      child: Center(child: Text(l10n.acctNoActivityHint)),
                    ),
                    data: (points) {
                      if (points.every((p) => p.debitCents == 0 && p.creditCents == 0)) {
                        return SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                              l10n.acctNoActivityHint,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        );
                      }
                      final chartData = points
                          .map(
                            (p) => _ActivityPoint(
                              _shortMonth(p.label),
                              p.debitCents / 100,
                              p.creditCents / 100,
                            ),
                          )
                          .toList();
                      return SizedBox(
                        height: 260,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: const CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            numberFormat: NumberFormat.compactCurrency(
                              symbol: currency == 'USD' ? '\$' : currency,
                            ),
                          ),
                          tooltipBehavior:
                              kIsWeb ? null : TooltipBehavior(enable: true),
                          legend: const Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<_ActivityPoint, String>(
                              name: 'Debit',
                              dataSource: chartData,
                              xValueMapper: (d, _) => d.label,
                              yValueMapper: (d, _) => d.debit,
                              color: InventraXTheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              width: 0.5,
                            ),
                            ColumnSeries<_ActivityPoint, String>(
                              name: 'Credit',
                              dataSource: chartData,
                              xValueMapper: (d, _) => d.label,
                              yValueMapper: (d, _) => d.credit,
                              color: AppCharts.sales(Theme.of(context).brightness),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              width: 0.5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AccountingSectionTitle(
                  label: l10n.acctNavGeneralLedger,
                  count: ledger.asData?.value.length,
                  color: accountTypeColor(account.type),
                ),
                ledger.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(l10n.acctErrorDetail(e.toString())),
                  data: (lines) {
                    if (lines.isEmpty) {
                      return AccountingSurfaceCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            l10n.acctNoActivityHint,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final l in lines.reversed.take(20))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AccountingSurfaceCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateFmt.format(l.entryDate),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (l.debitCents > 0)
                                        Text(
                                          'Dr ${formatMoney(l.debitCents, currency: currency)}',
                                        ),
                                      if (l.creditCents > 0)
                                        Text(
                                          'Cr ${formatMoney(l.creditCents, currency: currency)}',
                                        ),
                                      Text(
                                        formatMoney(
                                          l.runningBalanceCents,
                                          currency: currency,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (account.isActive)
                  FilledButton.tonalIcon(
                    onPressed: canDelete
                        ? () => _confirmDelete(context, ref, account)
                        : null,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.acctDeleteDeactivate),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: () => _restoreAccount(context, ref, account),
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.acctRestoreAccount),
                  ),
                if (!canDelete && account.isActive) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.acctCannotDeleteWithBalance,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _shortMonth(String ym) {
    final parts = ym.split('-');
    if (parts.length != 2) return ym;
    final month = int.tryParse(parts[1]) ?? 1;
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ChartOfAccount account,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.acctDeleteAccountTitle),
        content: Text(l10n.acctDeleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await ref.read(appDatabaseProvider).setChartAccountActive(
            accountId: account.id,
            isActive: false,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctAccountUpdated(account.name))),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _restoreAccount(
    BuildContext context,
    WidgetRef ref,
    ChartOfAccount account,
  ) async {
    final l10n = context.l10n;
    try {
      await ref.read(appDatabaseProvider).setChartAccountActive(
            accountId: account.id,
            isActive: true,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctAccountUpdated(account.name))),
        );
        ref.invalidate(accountDetailProvider(accountId));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }
}

class _ActivityPoint {
  const _ActivityPoint(this.label, this.debit, this.credit);
  final String label;
  final double debit;
  final double credit;
}
