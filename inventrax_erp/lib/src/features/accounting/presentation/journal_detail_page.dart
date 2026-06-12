import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

final journalDetailProvider =
    FutureProvider.autoDispose.family<JournalDetailBundle?, String>(
  (ref, journalId) async {
    ref.watch(accountingInitProvider);
    final db = ref.watch(appDatabaseProvider);
    final entry = await db.getJournalEntryById(journalId);
    if (entry == null) return null;
    final lines = await db.listLinesForJournal(journalId);
    return JournalDetailBundle(entry: entry, lines: lines);
  },
);

class JournalDetailBundle {
  const JournalDetailBundle({required this.entry, required this.lines});
  final JournalEntry entry;
  final List<JournalLine> lines;
}

class JournalDetailPage extends ConsumerWidget {
  const JournalDetailPage({super.key, required this.journalId});

  final String journalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(storeCurrencyProvider);
    final detail = ref.watch(journalDetailProvider(journalId));
    final accounts = ref.watch(chartOfAccountsProvider);

    return AccountingShell(
      title: l10n.acctJournals,
      child: detail.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (bundle) {
          if (bundle == null) {
            return AccountingEmptyState(
              title: l10n.acctNoJournalEntries,
              subtitle: l10n.acctJournals,
              icon: Icons.search_off_outlined,
            );
          }

          final entry = bundle.entry;
          final lines = bundle.lines;
          final byId = {
            for (final a in accounts.value ?? []) a.id: a,
          };

          var totalDebit = 0;
          var totalCredit = 0;
          for (final l in lines) {
            totalDebit += l.debitCents;
            totalCredit += l.creditCents;
          }
          final balanced = totalDebit == totalCredit;

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: entry.description,
                  subtitle: DateFormat.yMMMd().add_jm().format(entry.entryDate),
                  trailing: IconButton(
                    tooltip: l10n.commonClose,
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Row(
                  children: [
                    AccountingSourceChip(source: entry.sourceModule),
                    if (entry.sourceId != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '#${entry.sourceId!.substring(0, 8)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                AccountingStatusBanner(
                  ok: balanced,
                  title: balanced ? l10n.acctBooksBalanced : l10n.acctOutOfBalance,
                  subtitle:
                      '${l10n.acctDebitTotal}: ${formatMoney(totalDebit, currency: currency)} · '
                      '${l10n.acctCreditTotal}: ${formatMoney(totalCredit, currency: currency)}',
                ),
                const SizedBox(height: 16),
                AccountingSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < lines.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        _JournalLineRow(
                          line: lines[i],
                          account: byId[lines[i].accountId],
                          currency: currency,
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: InventraXTheme.primary.withValues(alpha: 0.06),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.commonTotal,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              formatMoney(totalDebit, currency: currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: InventraXTheme.primary,
                                  ),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              formatMoney(totalCredit, currency: currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: InventraXTheme.accent,
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
        },
      ),
    );
  }
}

class _JournalLineRow extends StatelessWidget {
  const _JournalLineRow({
    required this.line,
    required this.account,
    required this.currency,
  });

  final JournalLine line;
  final ChartOfAccount? account;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDebit = line.debitCents > 0;
    final amount = isDebit ? line.debitCents : line.creditCents;
    final color = isDebit ? InventraXTheme.primary : InventraXTheme.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account?.name ?? line.accountId,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (account != null)
                  Text(
                    account!.code,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isDebit ? 'Dr' : 'Cr'} ${formatMoney(amount, currency: currency)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
