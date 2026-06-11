import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/store_context.dart';
import '../../../../core/ux/feedback_service.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/db_provider.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../../accounting/data/accounting_provider.dart';
import '../../../dashboard/dashboard_providers.dart';

class DebtPaymentResult {
  const DebtPaymentResult({
    required this.amountCents,
    required this.paymentAccountId,
    required this.paymentAccountName,
    this.method,
    this.notes,
  });

  final int amountCents;
  final String paymentAccountId;
  final String paymentAccountName;
  final String? method;
  final String? notes;
}

Future<DebtPaymentResult?> showDebtPaymentDialog(
  BuildContext context,
  WidgetRef ref, {
  required int maxCents,
  required String currency,
  String? title,
}) async {
  final db = ref.read(appDatabaseProvider);
  await db.ensureAccountingSeeded(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
  final accounts =
      await db.listPaymentAccounts(storeId: StoreContext.storeId);
  if (!context.mounted) return null;

  final l10n = context.l10n;
  return showDialog<DebtPaymentResult>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _DebtPaymentDialog(
      maxCents: maxCents,
      currency: currency,
      accounts: accounts,
      title: title ?? l10n.recordPayment,
    ),
  );
}

class _DebtPaymentDialog extends StatefulWidget {
  const _DebtPaymentDialog({
    required this.maxCents,
    required this.currency,
    required this.accounts,
    required this.title,
  });

  final int maxCents;
  final String currency;
  final List<PaymentAccount> accounts;
  final String title;

  @override
  State<_DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends State<_DebtPaymentDialog> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  PaymentAccount? _account;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _account = widget.accounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => widget.accounts.first,
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int _toCents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cents = _toCents(_amount.text);
    if (cents <= 0) return;
    final l10n = context.l10n;
    if (cents > widget.maxCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.debtPaymentExceeds(
              formatMoney(widget.maxCents, currency: widget.currency),
            ),
          ),
        ),
      );
      return;
    }
    final acc = _account ?? widget.accounts.firstOrNull;
    if (acc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.debtSelectPaymentAccount)),
      );
      return;
    }
    Navigator.pop(
      context,
      DebtPaymentResult(
        amountCents: cents,
        paymentAccountId: acc.id,
        paymentAccountName: acc.name,
        method: acc.accountType,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxLabel = formatMoney(widget.maxCents, currency: widget.currency);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.debtBalanceDue(maxLabel)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amount,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.debtPaymentAmount,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notes,
                  decoration: InputDecoration(labelText: l10n.posNotesOptional),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.posPaymentAccount,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.accounts.isEmpty)
                  Text(l10n.debtNoWallets)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.accounts.map((a) {
                      final selected = _account?.id == a.id;
                      return ChoiceChip(
                        label: Text(a.name),
                        selected: selected,
                        onSelected: (_) => setState(() => _account = a),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.recordPayment),
        ),
      ],
    );
  }
}

/// Local-first payment: UI updates immediately; accounting + sync run in background.
Future<int> applyDebtPayment({
  required WidgetRef ref,
  required BuildContext context,
  required Debt debt,
  required DebtPaymentResult payment,
}) async {
  final db = ref.read(appDatabaseProvider);
  await db.recordDebtPayment(
    debtId: debt.id,
    tenantId: debt.tenantId,
    storeId: debt.storeId,
    amountCents: payment.amountCents,
    method: payment.method,
    notes: payment.notes,
    paymentAccountId: payment.paymentAccountId,
    userId: StoreContext.userId,
  );

  final remaining =
      (debt.remainingCents - payment.amountCents).clamp(0, debt.remainingCents);

  unawaited(
    ref.read(accountingEngineProvider).postDebtPayment(
          debt: debt,
          amountCents: payment.amountCents,
          method: payment.method,
          paymentAccountId: payment.paymentAccountId,
        ),
  );

  ref.read(feedbackServiceProvider).checkoutSuccess();
  invalidateDashboardMetrics(ref);

  if (context.mounted) {
    final l10n = context.l10n;
    final currency =
        ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: InventraXTheme.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.debtPaymentRecorded,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.debtPaymentRemainingSync(
                      formatMoney(remaining, currency: currency),
                    ),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  return remaining;
}
