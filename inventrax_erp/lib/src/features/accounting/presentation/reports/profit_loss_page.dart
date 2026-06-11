import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/store_context.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../data/accounting_provider.dart';
import '../../domain/accounting_constants.dart';
import '../accounting_shell.dart';
import '../widgets/accounting_export_actions.dart';
import '../widgets/accounting_ui.dart';

final profitLossProvider =
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

class ProfitLossPage extends ConsumerWidget {
  const ProfitLossPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(storeCurrencyProvider);
    final data = ref.watch(profitLossProvider);
    final period = DateFormat.yMMMM().format(DateTime.now());

    return AccountingShell(
      title: 'Profit & loss',
      actions: [
        AccountingExportButton(
          filename: 'profit_loss.pdf',
          buildPdf: (service) async {
            final rows = await ref.read(profitLossProvider.future);
            var revenue = 0;
            var cogs = 0;
            var expenses = 0;
            final expenseLines = <({String name, int cents})>[];
            for (final r in rows) {
              if (r.account.type == AccountType.revenue) {
                revenue += r.balanceCents;
              } else if (r.account.code == AcctCode.cogs) {
                cogs += r.balanceCents;
              } else if (r.account.type == AccountType.expense) {
                expenses += r.balanceCents;
                expenseLines.add((name: r.account.name, cents: r.balanceCents));
              }
            }
            final now = DateTime.now();
            final start = DateTime(now.year, now.month, 1);
            final currency = ref.read(storeCurrencyProvider);
            final pdf = service.buildProfitLossPdf(
              storeName: accountingStoreLabel(ref),
              from: start,
              to: now,
              revenue: revenue,
              cogs: cogs,
              expenses: expenses,
              netProfit: revenue - cogs - expenses,
              expenseLines: expenseLines,
              currency: currency,
            );
            return pdf.save();
          },
        ),
        const SizedBox(width: 8),
      ],
      child: data.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          var revenue = 0;
          var cogs = 0;
          var expenses = 0;
          final expenseLines = <AccountBalanceRow>[];

          for (final r in rows) {
            if (r.account.type == AccountType.revenue) {
              revenue += r.balanceCents;
            } else if (r.account.code == AcctCode.cogs) {
              cogs += r.balanceCents;
            } else if (r.account.type == AccountType.expense) {
              expenses += r.balanceCents;
              expenseLines.add(r);
            }
          }
          final gross = revenue - cogs;
          final net = gross - expenses;

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: 'Profit & loss',
                  subtitle: 'Income statement · $period',
                ),
                AccountingSurfaceCard(
                  child: Column(
                    children: [
                      AccountingReportLine(
                        label: 'Revenue',
                        amount: formatMoney(revenue, currency: currency),
                        highlight: true,
                      ),
                      AccountingReportLine(
                        label: 'Cost of goods sold',
                        amount: formatMoney(-cogs, currency: currency),
                        negative: true,
                      ),
                      const Divider(),
                      AccountingReportLine(
                        label: 'Gross profit',
                        amount: formatMoney(gross, currency: currency),
                        bold: true,
                        highlight: gross >= 0,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Operating expenses',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      for (final e in expenseLines)
                        AccountingReportLine(
                          label: e.account.name,
                          amount: formatMoney(-e.balanceCents, currency: currency),
                          indent: true,
                          negative: true,
                        ),
                      if (expenseLines.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No expense activity this period',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      const Divider(),
                      AccountingReportLine(
                        label: 'Net profit',
                        amount: formatMoney(net, currency: currency),
                        bold: true,
                        highlight: net >= 0,
                        negative: net < 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
