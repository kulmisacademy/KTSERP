import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class PaymentAccountsPage extends ConsumerWidget {
  const PaymentAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(paymentAccountsProvider);

    final l10n = context.l10n;
    return AccountingShell(
      title: l10n.acctNavPaymentAccounts,
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
            );
          }

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctNavPaymentAccounts,
                  subtitle:
                      '${rows.length} wallets linked to checkout and accounting — Cash, bank, and mobile money',
                ),
                for (final a in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PaymentWalletCard(
                      name: a.name,
                      accountType: a.accountType,
                      isDefault: a.isDefault,
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
