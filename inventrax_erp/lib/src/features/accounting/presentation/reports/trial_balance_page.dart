import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/store_context.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../data/accounting_provider.dart';
import '../accounting_shell.dart';
import '../widgets/accounting_export_actions.dart';
import '../widgets/accounting_report_widgets.dart';
import '../widgets/accounting_ui.dart';

final trialBalanceProvider =
    FutureProvider.autoDispose<List<AccountBalanceRow>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, 1, 1);
  return db.accountBalances(
    storeId: StoreContext.storeId,
    from: start,
    to: now,
  );
});

class TrialBalancePage extends ConsumerWidget {
  const TrialBalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(storeCurrencyProvider);
    final data = ref.watch(trialBalanceProvider);
    final asOf = DateFormat.yMMMd().format(DateTime.now());

    return AccountingShell(
      title: 'Trial balance',
      child: data.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          var totalDebit = 0;
          var totalCredit = 0;
          for (final r in rows) {
            totalDebit += r.debitCents;
            totalCredit += r.creditCents;
          }
          final balanced = totalDebit == totalCredit;

          return AccountingReportScaffold(
            title: 'Trial balance',
            subtitle: 'Year to date · As of $asOf',
            exportFilename: 'trial_balance.pdf',
            buildPdf: (service) async {
              final pdfRows = await ref.read(trialBalanceProvider.future);
              var td = 0;
              var tc = 0;
              for (final r in pdfRows) {
                td += r.debitCents;
                tc += r.creditCents;
              }
              final pdf = service.buildTrialBalancePdf(
                storeName: accountingStoreLabel(ref),
                asOf: DateTime.now(),
                rows: pdfRows,
                totalDebit: td,
                totalCredit: tc,
                currency: ref.read(storeCurrencyProvider),
              );
              return pdf.save();
            },
            statusOk: balanced,
            statusTitle: balanced ? 'Books balanced' : 'Out of balance',
            statusSubtitle:
                'Debits ${formatMoney(totalDebit, currency: currency)} · '
                'Credits ${formatMoney(totalCredit, currency: currency)}',
            metrics: [
              AccountingReportMetric(
                label: 'Total debits',
                value: formatMoney(totalDebit, currency: currency),
                icon: Icons.arrow_downward_rounded,
                color: InventraXTheme.primary,
              ),
              AccountingReportMetric(
                label: 'Total credits',
                value: formatMoney(totalCredit, currency: currency),
                icon: Icons.arrow_upward_rounded,
                color: InventraXTheme.accent,
              ),
            ],
            children: [
              AccountingReportTable(
                columns: const [
                  'Code',
                  'Account',
                  'Debit',
                  'Credit',
                  'Balance',
                ],
                rows: [
                  for (final r in rows)
                    [
                      r.account.code,
                      r.account.name,
                      r.debitCents > 0
                          ? formatMoney(r.debitCents, currency: currency)
                          : '—',
                      r.creditCents > 0
                          ? formatMoney(r.creditCents, currency: currency)
                          : '—',
                      formatMoney(r.balanceCents, currency: currency),
                    ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
