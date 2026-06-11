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

final balanceSheetProvider =
    FutureProvider.autoDispose<List<AccountBalanceRow>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.accountBalances(storeId: StoreContext.storeId);
});

class BalanceSheetPage extends ConsumerWidget {
  const BalanceSheetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(storeCurrencyProvider);
    final data = ref.watch(balanceSheetProvider);
    final asOf = DateFormat.yMMMd().format(DateTime.now());

    return AccountingShell(
      title: 'Balance sheet',
      actions: [
        AccountingExportButton(
          filename: 'balance_sheet.pdf',
          buildPdf: (service) async {
            final rows = await ref.read(balanceSheetProvider.future);
            final assets =
                rows.where((r) => r.account.type == AccountType.asset).toList();
            final liabilities = rows
                .where((r) => r.account.type == AccountType.liability)
                .toList();
            final equity =
                rows.where((r) => r.account.type == AccountType.equity).toList();
            var ta = 0, tl = 0, te = 0;
            for (final r in assets) {
              ta += r.balanceCents;
            }
            for (final r in liabilities) {
              tl += r.balanceCents;
            }
            for (final r in equity) {
              te += r.balanceCents;
            }
            final currency = ref.read(storeCurrencyProvider);
            final pdf = service.buildBalanceSheetPdf(
              storeName: accountingStoreLabel(ref),
              asOf: DateTime.now(),
              assets: assets,
              liabilities: liabilities,
              equity: equity,
              totalAssets: ta,
              totalLiabilities: tl,
              totalEquity: te,
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
          var assets = 0;
          var liabilities = 0;
          var equity = 0;

          for (final r in rows) {
            switch (r.account.type) {
              case AccountType.asset:
                assets += r.balanceCents;
              case AccountType.liability:
                liabilities += r.balanceCents;
              case AccountType.equity:
                equity += r.balanceCents;
            }
          }
          final equationOk = assets == liabilities + equity;

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: 'Balance sheet',
                  subtitle: 'Assets, liabilities & equity · As of $asOf',
                ),
                AccountingStatusBanner(
                  ok: equationOk,
                  title: 'Assets = Liabilities + Equity',
                  subtitle:
                      '${formatMoney(assets, currency: currency)} = '
                      '${formatMoney(liabilities + equity, currency: currency)}',
                ),
                const SizedBox(height: 20),
                _ReportSection(
                  title: 'Assets',
                  rows: rows,
                  type: AccountType.asset,
                  currency: currency,
                  color: accountTypeColor(AccountType.asset),
                ),
                _ReportSection(
                  title: 'Liabilities',
                  rows: rows,
                  type: AccountType.liability,
                  currency: currency,
                  color: accountTypeColor(AccountType.liability),
                ),
                _ReportSection(
                  title: 'Equity',
                  rows: rows,
                  type: AccountType.equity,
                  currency: currency,
                  color: accountTypeColor(AccountType.equity),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.rows,
    required this.type,
    required this.currency,
    required this.color,
  });

  final String title;
  final List<AccountBalanceRow> rows;
  final String type;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final section = rows.where((r) => r.account.type == type).toList();
    var total = 0;
    for (final r in section) {
      total += r.balanceCents;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountingSectionTitle(
            label: title,
            count: section.length,
            color: color,
          ),
          AccountingSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < section.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            section[i].account.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(
                          formatMoney(section[i].balanceCents, currency: currency),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Total $title',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        formatMoney(total, currency: currency),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
