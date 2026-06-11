import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';

enum PurchasePaymentMode { full, partial, credit }

class PurchaseCheckoutSelection {
  const PurchaseCheckoutSelection({
    required this.paymentAccountId,
    required this.paymentAccountName,
    this.mode = PurchasePaymentMode.full,
    this.paidCents,
    this.notes,
  })  : isCredit = false;

  const PurchaseCheckoutSelection.credit({this.notes})
      : paymentAccountId = null,
        paymentAccountName = 'Credit (Accounts Payable)',
        mode = PurchasePaymentMode.credit,
        paidCents = 0,
        isCredit = true;

  const PurchaseCheckoutSelection.partial({
    required this.paymentAccountId,
    required this.paymentAccountName,
    required this.paidCents,
    this.notes,
  })  : mode = PurchasePaymentMode.partial,
        isCredit = false;

  final String? paymentAccountId;
  final String paymentAccountName;
  final PurchasePaymentMode mode;
  final int? paidCents;
  final bool isCredit;
  final String? notes;
}

Future<List<PaymentAccount>> _loadAccounts(WidgetRef ref) async {
  final db = ref.read(appDatabaseProvider);
  await db.ensureAccountingSeeded(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
  return db.listPaymentAccounts(storeId: StoreContext.storeId);
}

IconData _iconForType(String type) {
  return switch (type) {
    'bank' => Icons.account_balance,
    'mobile' => Icons.phone_android,
    _ => Icons.payments,
  };
}

Future<PurchaseCheckoutSelection?> showPurchaseCheckoutSheet(
  BuildContext context,
  WidgetRef ref, {
  required int totalCents,
  String? initialNotes,
}) async {
  List<PaymentAccount> accounts;
  try {
    accounts = await _loadAccounts(ref);
  } catch (e) {
    if (context.mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchaseCouldNotLoadAccounts(e.toString()))),
      );
    }
    accounts = [];
  }
  if (!context.mounted) return null;

  return showModalBottomSheet<PurchaseCheckoutSelection>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    isDismissible: true,
    builder: (ctx) => _PurchaseCheckoutBody(
      totalCents: totalCents,
      accounts: accounts,
      initialNotes: initialNotes,
      currency: ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD',
    ),
  );
}

class _PurchaseCheckoutBody extends StatefulWidget {
  const _PurchaseCheckoutBody({
    required this.totalCents,
    required this.accounts,
    this.initialNotes,
    required this.currency,
  });

  final int totalCents;
  final List<PaymentAccount> accounts;
  final String? initialNotes;
  final String currency;

  @override
  State<_PurchaseCheckoutBody> createState() => _PurchaseCheckoutBodyState();
}

class _PurchaseCheckoutBodyState extends State<_PurchaseCheckoutBody> {
  PurchasePaymentMode _mode = PurchasePaymentMode.full;
  final _partialCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  PaymentAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    if (widget.initialNotes != null) {
      _notesCtrl.text = widget.initialNotes!;
    }
    if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => widget.accounts.first,
      );
    }
  }

  @override
  void dispose() {
    _partialCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _totalLabel =>
      formatMoney(widget.totalCents, currency: widget.currency);

  String? get _notes =>
      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

  int? _partialCents() {
    final v = double.tryParse(_partialCtrl.text.trim());
    if (v == null) return null;
    return (v * 100).round();
  }

  void _confirm() {
    if (_mode == PurchasePaymentMode.credit) {
      Navigator.pop(
        context,
        PurchaseCheckoutSelection.credit(notes: _notes),
      );
      return;
    }

    final account = _selectedAccount;
    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.purchaseSelectPayAccount)),
      );
      return;
    }

    if (_mode == PurchasePaymentMode.partial) {
      final cents = _partialCents();
      if (cents == null || cents <= 0 || cents >= widget.totalCents) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.posInvalidPartialAmount)),
        );
        return;
      }
      Navigator.pop(
        context,
        PurchaseCheckoutSelection.partial(
          paymentAccountId: account.id,
          paymentAccountName: account.name,
          paidCents: cents,
          notes: _notes,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      PurchaseCheckoutSelection(
        paymentAccountId: account.id,
        paymentAccountName: account.name,
        mode: PurchasePaymentMode.full,
        paidCents: widget.totalCents,
        notes: _notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final remainingCents = (widget.totalCents - (_partialCents() ?? 0))
        .clamp(0, widget.totalCents);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.purchaseCompleteTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.purchaseTotal(_totalLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<PurchasePaymentMode>(
                      segments: [
                        ButtonSegment(
                          value: PurchasePaymentMode.full,
                          label: Text(l10n.posPaymentFull),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                        ),
                        ButtonSegment(
                          value: PurchasePaymentMode.partial,
                          label: Text(l10n.posPaymentPartial),
                          icon: const Icon(Icons.pie_chart_outline, size: 18),
                        ),
                        ButtonSegment(
                          value: PurchasePaymentMode.credit,
                          label: Text(l10n.posPaymentCredit),
                          icon: const Icon(Icons.credit_score, size: 18),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (s) => setState(() => _mode = s.first),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.posNotesOptional,
                        isDense: true,
                      ),
                      maxLines: 2,
                    ),
                    if (_mode == PurchasePaymentMode.partial) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _partialCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.purchaseAmountPaidNow,
                          helperText: l10n.purchaseRemainingToDebt(
                            formatMoney(remainingCents, currency: widget.currency),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    if (_mode == PurchasePaymentMode.credit) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: theme.colorScheme.tertiaryContainer
                            .withValues(alpha: 0.4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.credit_score_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.purchaseCreditNoPayment(_totalLabel),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.purchasePayFromAccount,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      if (widget.accounts.isEmpty)
                        Text(
                          l10n.purchaseSetupAccountsFirst,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        )
                      else
                        ...widget.accounts.map(
                          (a) => RadioListTile<PaymentAccount>(
                            value: a,
                            groupValue: _selectedAccount,
                            title: Text(a.name),
                            subtitle: Text(a.accountType),
                            secondary: Icon(_iconForType(a.accountType)),
                            onChanged: (v) =>
                                setState(() => _selectedAccount = v),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check),
                      label: Text(
                        _mode == PurchasePaymentMode.credit
                            ? l10n.purchaseSaveOnCredit
                            : l10n.purchaseSavePurchase,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
