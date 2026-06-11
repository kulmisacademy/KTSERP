import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/acct_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class GeneralLedgerPage extends ConsumerStatefulWidget {
  const GeneralLedgerPage({super.key});

  @override
  ConsumerState<GeneralLedgerPage> createState() => _GeneralLedgerPageState();
}

class _GeneralLedgerPageState extends ConsumerState<GeneralLedgerPage> {
  String? _accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = ref.watch(storeCurrencyProvider);
    final accounts = ref.watch(chartOfAccountsProvider);
    final dateFmt = DateFormat('MMM d, yyyy');

    return AccountingShell(
      title: l10n.acctNavGeneralLedger,
      child: accounts.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (accts) {
          final selected = _accountId ??
              (accts.isNotEmpty ? accts.first.id : null);
          final selectedAcct =
              accts.where((a) => a.id == selected).firstOrNull;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountingPageBody(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AccountingPageHeader(
                      title: l10n.acctNavGeneralLedger,
                      subtitle: l10n.acctSelectAccountSubtitle,
                    ),
                    AccountingSurfaceCard(
                      child: DropdownButtonFormField<String>(
                        value: selected,
                        decoration: InputDecoration(
                          labelText: 'Account',
                          prefixIcon: const Icon(Icons.account_tree_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: accts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text('${a.code} — ${a.name}'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _accountId = v),
                      ),
                    ),
                    if (selectedAcct != null) ...[
                      const SizedBox(height: 12),
                      AccountingSurfaceCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accountTypeColor(selectedAcct.type)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                selectedAcct.code,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: accountTypeColor(selectedAcct.type),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedAcct.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    localizedAccountTypeLabel(l10n, selectedAcct.type),
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
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: selected == null
                    ? const AccountingEmptyState(
                        title: 'Select an account',
                        subtitle: 'Choose an account to view its ledger activity',
                        icon: Icons.receipt_long_outlined,
                      )
                    : FutureBuilder<List<LedgerLineRow>>(
                        future: ref.read(appDatabaseProvider).ledgerForAccount(
                              accountId: selected,
                            ),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const AccountingLoadingState();
                          }
                          final lines = snap.data ?? [];
                          if (lines.isEmpty) {
                            return const AccountingEmptyState(
                              title: 'No activity',
                              subtitle:
                                  'Transactions for this account will appear here',
                              icon: Icons.history,
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: lines.length,
                            itemBuilder: (context, i) {
                              final l = lines[i];
                              return Padding(
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
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  dateFmt.format(l.entryDate),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                AccountingSourceChip(
                                                  source: l.sourceModule,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (l.debitCents > 0)
                                            Text(
                                              'Dr ${formatMoney(l.debitCents, currency: currency)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: InventraXTheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          if (l.creditCents > 0)
                                            Text(
                                              'Cr ${formatMoney(l.creditCents, currency: currency)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: InventraXTheme.accent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          const SizedBox(height: 4),
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
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
