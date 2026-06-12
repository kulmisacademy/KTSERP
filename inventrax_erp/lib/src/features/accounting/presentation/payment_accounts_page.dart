import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';
import 'widgets/payment_account_form_sheet.dart';

class PaymentAccountsPage extends ConsumerWidget {
  const PaymentAccountsPage({super.key});

  Future<void> _openForm(BuildContext context, {PaymentAccount? existing}) async {
    final saved = await showPaymentAccountFormSheet(context, existing: existing);
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.acctPaymentAccountSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(paymentAccountsProvider);

    final l10n = context.l10n;
    return AccountingShell(
      title: l10n.acctNavPaymentAccounts,
      actions: [
        FilledButton.icon(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.acctAddPaymentAccount),
          style: FilledButton.styleFrom(
            backgroundColor: InventraXTheme.accent,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
      ],
      child: accounts.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
        data: (rows) {
          if (rows.isEmpty) {
            return AccountingEmptyState(
              title: l10n.acctNoPaymentAccountsTitle,
              subtitle: l10n.acctPaymentAccountsAutoCreated,
              icon: Icons.account_balance_wallet_outlined,
              action: FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.acctAddPaymentAccount),
              ),
            );
          }

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctNavPaymentAccounts,
                  subtitle:
                      '${rows.length} wallets linked to checkout and accounting — ${l10n.acctTapToEditWallet}',
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
                        PaymentWalletCard(
                          name: rows[i].name,
                          accountType: rows[i].accountType,
                          isDefault: rows[i].isDefault,
                          onTap: () => _openForm(context, existing: rows[i]),
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
}
