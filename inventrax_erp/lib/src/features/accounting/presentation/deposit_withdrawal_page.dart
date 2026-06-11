import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../data/accounting_provider.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_ui.dart';

class DepositWithdrawalPage extends ConsumerStatefulWidget {
  const DepositWithdrawalPage({super.key});

  @override
  ConsumerState<DepositWithdrawalPage> createState() =>
      _DepositWithdrawalPageState();
}

class _DepositWithdrawalPageState extends ConsumerState<DepositWithdrawalPage> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String? _paymentAccountId;
  bool _isDeposit = true;
  bool _posting = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int _cents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payments = ref.watch(paymentAccountsProvider);

    return AccountingShell(
      title: l10n.acctNavDeposits,
      child: payments.when(
        loading: () => const AccountingLoadingState(),
        error: (e, _) => Center(child: Text(l10n.acctErrorDetail(e.toString()))),
        data: (accounts) {
          final selected = _paymentAccountId ??
              accounts.where((a) => a.isDefault).map((a) => a.id).firstOrNull ??
              accounts.firstOrNull?.id;

          return AccountingPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountingPageHeader(
                  title: l10n.acctOwnerCashMovements,
                  subtitle: l10n.acctOwnerCashSubtitle,
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(l10n.acctDeposit),
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.acctWithdrawal),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {_isDeposit},
                  onSelectionChanged: (s) =>
                      setState(() => _isDeposit = s.first),
                ),
                const SizedBox(height: 16),
                AccountingStatusBanner(
                  ok: true,
                  title: _isDeposit ? l10n.acctDepositEntry : l10n.acctWithdrawalEntry,
                  subtitle: _isDeposit
                      ? l10n.acctDepositBannerSubtitle
                      : l10n.acctWithdrawalBannerSubtitle,
                ),
                const SizedBox(height: 20),
                AccountingFormCard(
                  title: l10n.acctTransactionDetails,
                  children: [
                    if (accounts.isEmpty)
                      Text(l10n.acctNoPaymentAccountsConfigured)
                    else
                      DropdownButtonFormField<String>(
                        value: selected,
                        decoration: InputDecoration(
                          labelText: l10n.acctWalletAccount,
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: accounts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _paymentAccountId = v),
                      ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.acctAmount,
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.acctNotesOptional,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _posting || selected == null
                          ? null
                          : () => _post(selected),
                      icon: _posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _isDeposit ? l10n.acctPostDeposit : l10n.acctPostWithdrawal,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: InventraXTheme.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _post(String paymentAccountId) async {
    final l10n = context.l10n;
    final cents = _cents(_amount.text);
    if (cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.acctEnterValidAmount)),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      final engine = ref.read(accountingEngineProvider);
      if (_isDeposit) {
        await engine.postDeposit(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          amountCents: cents,
          paymentAccountId: paymentAccountId,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          userId: StoreContext.userId,
        );
      } else {
        await engine.postWithdrawal(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          amountCents: cents,
          paymentAccountId: paymentAccountId,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          userId: StoreContext.userId,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isDeposit ? l10n.acctDepositPosted : l10n.acctWithdrawalPosted,
            ),
          ),
        );
        _amount.clear();
        _notes.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.acctErrorDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }
}
