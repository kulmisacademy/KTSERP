import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/acct_l10n.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import '../domain/accounting_constants.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class ChartOfAccountsPage extends ConsumerStatefulWidget {
  const ChartOfAccountsPage({super.key});

  @override
  ConsumerState<ChartOfAccountsPage> createState() => _ChartOfAccountsPageState();
}

class _ChartOfAccountsPageState extends ConsumerState<ChartOfAccountsPage> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = ref.watch(storeCurrencyProvider);
    final accounts = ref.watch(chartOfAccountsAllProvider(_showInactive));
    final balances = ref.watch(chartAccountBalancesProvider);

    return AccountingShell(
      title: l10n.acctNavChartOfAccounts,
      actions: [
        IconButton(
          tooltip: _showInactive ? l10n.acctHideInactive : l10n.acctShowInactive,
          onPressed: () => setState(() => _showInactive = !_showInactive),
          icon: Icon(_showInactive ? Icons.visibility_off : Icons.visibility),
        ),
        FilledButton.tonalIcon(
          onPressed: () => _showAddAccountDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.acctAddAccount),
        ),
        const SizedBox(width: 8),
      ],
      child: accounts.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (rows) {
          final balanceMap = balances.asData?.value ?? {};
          final grouped = <String, List<ChartOfAccount>>{};
          for (final a in rows) {
            grouped.putIfAbsent(a.type, () => []).add(a);
          }
          const order = [
            AccountType.asset,
            AccountType.liability,
            AccountType.equity,
            AccountType.revenue,
            AccountType.expense,
          ];

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctNavChartOfAccounts,
                  subtitle: l10n.acctTapAccountHint,
                ),
                Text(
                  l10n.acctChartAccountsSubtitle(rows.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                for (final type in order)
                  if (grouped[type]?.isNotEmpty == true) ...[
                    AccountingSectionTitle(
                      label: localizedAccountTypeLabel(l10n, type),
                      count: grouped[type]!.length,
                      color: accountTypeColor(type),
                    ),
                    AccountingSurfaceCard(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          for (var i = 0; i < grouped[type]!.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                indent: 70,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            AccountListTile(
                              code: grouped[type]![i].code,
                              name: grouped[type]![i].name,
                              badge: grouped[type]![i].isSystem
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l10n.acctSystemBadge,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall,
                                      ),
                                    )
                                  : null,
                              trailing: balances.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      formatMoney(
                                        balanceMap[grouped[type]![i].id] ?? 0,
                                        currency: currency,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                              onTap: () => context.push(
                                '/accounting/chart/${grouped[type]![i].id}',
                              ),
                            ),
                          ],
                        ],
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

  Future<void> _showAddAccountDialog(BuildContext context) async {
    final l10n = context.l10n;
    final code = TextEditingController();
    final name = TextEditingController();
    final opening = TextEditingController(text: '0');
    var type = AccountType.expense;

    int cents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.acctAddAccountDialogTitle),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: code,
                decoration: InputDecoration(labelText: l10n.acctAccountCode),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.acctAccountNameLabel),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: l10n.acctAccountTypeLabel),
                items: [
                  DropdownMenuItem(
                    value: AccountType.asset,
                    child: Text(localizedAccountTypeOption(l10n, AccountType.asset)),
                  ),
                  DropdownMenuItem(
                    value: AccountType.liability,
                    child: Text(localizedAccountTypeOption(l10n, AccountType.liability)),
                  ),
                  DropdownMenuItem(
                    value: AccountType.equity,
                    child: Text(localizedAccountTypeOption(l10n, AccountType.equity)),
                  ),
                  DropdownMenuItem(
                    value: AccountType.revenue,
                    child: Text(localizedAccountTypeOption(l10n, AccountType.revenue)),
                  ),
                  DropdownMenuItem(
                    value: AccountType.expense,
                    child: Text(localizedAccountTypeOption(l10n, AccountType.expense)),
                  ),
                ],
                onChanged: (v) => type = v ?? AccountType.expense,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: opening,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.acctOpeningBalanceOptional),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.acctCreateButton),
          ),
        ],
      ),
    );

    final codeText = code.text;
    final nameText = name.text;
    final openingText = opening.text;
    code.dispose();
    name.dispose();
    opening.dispose();
    if (ok != true) return;

    try {
      await ref.read(appDatabaseProvider).createChartAccount(
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            code: codeText,
            name: nameText,
            type: type,
            openingBalanceCents: cents(openingText),
          );
      ref.invalidate(chartAccountBalancesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctAccountCreated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }
}
