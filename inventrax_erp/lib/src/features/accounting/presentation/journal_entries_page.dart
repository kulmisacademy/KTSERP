import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

final journalListProvider =
    FutureProvider.autoDispose<List<JournalEntry>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1).subtract(const Duration(days: 365));
  return db.listJournalEntries(
    storeId: StoreContext.storeId,
    from: from,
    limit: 200,
  );
});

class JournalEntriesPage extends ConsumerWidget {
  const JournalEntriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalListProvider);
    final currency = ref.watch(storeCurrencyProvider);
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat.jm();

    final l10n = context.l10n;
    return AccountingShell(
      title: l10n.acctJournals,
      actions: [
        FilledButton.icon(
          onPressed: () => context.push('/accounting/journals/new'),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.acctNewEntry),
          style: FilledButton.styleFrom(
            backgroundColor: InventraXTheme.accent,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
      ],
      child: entries.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
        data: (rows) {
          if (rows.isEmpty) {
            return AccountingEmptyState(
              title: l10n.acctNoJournalEntries,
              subtitle: l10n.acctNoActivityHint,
              icon: Icons.menu_book_outlined,
              action: FilledButton.icon(
                onPressed: () => context.push('/accounting/journals/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.acctCreateManualEntry),
              ),
            );
          }

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctJournals,
                  subtitle: l10n.acctPostedEntriesCount(rows.length),
                ),
                AccountingSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        _JournalRow(
                          entry: rows[i],
                          dateFmt: dateFmt,
                          timeFmt: timeFmt,
                          onTap: () => _showDetail(context, ref, rows[i], currency),
                        ),
                      ],
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

  Future<void> _showDetail(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
    String currency,
  ) async {
    final db = ref.read(appDatabaseProvider);
    final lines = await db.listLinesForJournal(entry.id);
    final accounts = await ref.read(chartOfAccountsProvider.future);
    final byId = {for (final a in accounts) a.id: a};

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(child: Text(entry.description)),
            AccountingSourceChip(source: entry.sourceModule),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat.yMMMd().add_jm().format(entry.entryDate),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              for (final l in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${byId[l.accountId]?.code ?? ''} ${byId[l.accountId]?.name ?? l.accountId}',
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: l.debitCents > 0
                              ? InventraXTheme.primary.withValues(alpha: 0.1)
                              : InventraXTheme.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l.debitCents > 0
                              ? 'Dr ${formatMoney(l.debitCents, currency: currency)}'
                              : 'Cr ${formatMoney(l.creditCents, currency: currency)}',
                          style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: l.debitCents > 0
                                    ? InventraXTheme.primary
                                    : InventraXTheme.accent,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _JournalRow extends StatelessWidget {
  const _JournalRow({
    required this.entry,
    required this.dateFmt,
    required this.timeFmt,
    required this.onTap,
  });

  final JournalEntry entry;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: InventraXTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: InventraXTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${dateFmt.format(entry.entryDate)} · ${timeFmt.format(entry.entryDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                        AccountingSourceChip(source: entry.sourceModule),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
