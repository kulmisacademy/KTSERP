import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';

enum PosPaymentMode { full, partial, credit, split }

/// Result of the POS payment bottom sheet.
class PosCheckoutSelection {
  const PosCheckoutSelection({
    required this.paymentAccountId,
    required this.paymentAccountName,
    this.mode = PosPaymentMode.full,
    this.paidCents,
    this.customerId,
    this.customerName,
    this.notes,
    this.dueDate,
  })  : isCredit = false,
        isSplit = false;

  const PosCheckoutSelection.credit({
    this.customerId,
    this.customerName,
    this.notes,
    this.dueDate,
  })  : paymentAccountId = null,
        paymentAccountName = 'Credit (Accounts Receivable)',
        mode = PosPaymentMode.credit,
        paidCents = 0,
        isCredit = true,
        isSplit = false;

  const PosCheckoutSelection.partial({
    required this.paymentAccountId,
    required this.paymentAccountName,
    required this.paidCents,
    this.customerId,
    this.customerName,
    this.notes,
    this.dueDate,
  })  : mode = PosPaymentMode.partial,
        isCredit = false,
        isSplit = false;

  const PosCheckoutSelection.split({this.notes, this.dueDate})
      : paymentAccountId = null,
        paymentAccountName = 'Split',
        mode = PosPaymentMode.split,
        paidCents = null,
        isCredit = false,
        isSplit = true,
        customerId = null,
        customerName = null;

  const PosCheckoutSelection.cashFallback({this.notes, this.dueDate})
      : paymentAccountId = null,
        paymentAccountName = 'Cash',
        mode = PosPaymentMode.full,
        paidCents = null,
        isCredit = false,
        isSplit = false,
        customerId = null,
        customerName = null;

  final String? paymentAccountId;
  final String paymentAccountName;
  final PosPaymentMode mode;
  final int? paidCents;
  final bool isCredit;
  final bool isSplit;
  final String? customerId;
  final String? customerName;
  final String? notes;
  final DateTime? dueDate;

  bool get needsCustomer =>
      mode == PosPaymentMode.partial || mode == PosPaymentMode.credit;
}

typedef PosCustomerPicker = Future<({String id, String name})?> Function();

IconData _iconForType(String type) {
  return switch (type) {
    'bank' => Icons.account_balance,
    'mobile' => Icons.phone_android,
    _ => Icons.payments,
  };
}

Future<List<PaymentAccount>> _loadPaymentAccounts(WidgetRef ref) async {
  final db = ref.read(appDatabaseProvider);
  await db.ensureAccountingSeeded(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
  return db.listPaymentAccounts(storeId: StoreContext.storeId);
}

Future<PosCheckoutSelection?> showPosCheckoutSheet(
  BuildContext context,
  WidgetRef ref, {
  required int totalCents,
  String? customerId,
  String? customerName,
  String? initialNotes,
  required PosCustomerPicker onPickCustomer,
  required PosCustomerPicker onQuickAddCustomer,
}) async {
  List<PaymentAccount> accounts;
  try {
    accounts = await _loadPaymentAccounts(ref);
  } catch (e) {
    if (context.mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.posPaymentAccountsError(e.toString()))),
      );
    }
    accounts = [];
  }
  if (!context.mounted) return null;

  return showModalBottomSheet<PosCheckoutSelection>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _CheckoutSheetBody(
      totalCents: totalCents,
      accounts: accounts,
      currency: ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD',
      initialCustomerId: customerId,
      initialCustomerName: customerName,
      initialNotes: initialNotes,
      onPickCustomer: onPickCustomer,
      onQuickAddCustomer: onQuickAddCustomer,
    ),
  );
}

class _CheckoutSheetBody extends StatefulWidget {
  const _CheckoutSheetBody({
    required this.totalCents,
    required this.accounts,
    required this.currency,
    this.initialCustomerId,
    this.initialCustomerName,
    this.initialNotes,
    required this.onPickCustomer,
    required this.onQuickAddCustomer,
  });

  final int totalCents;
  final List<PaymentAccount> accounts;
  final String currency;
  final String? initialCustomerId;
  final String? initialCustomerName;
  final String? initialNotes;
  final PosCustomerPicker onPickCustomer;
  final PosCustomerPicker onQuickAddCustomer;

  @override
  State<_CheckoutSheetBody> createState() => _CheckoutSheetBodyState();
}

class _CheckoutSheetBodyState extends State<_CheckoutSheetBody> {
  PosPaymentMode _mode = PosPaymentMode.full;
  final _partialCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _customerId;
  String? _customerName;
  DateTime? _dueDate;
  PaymentAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _customerId = widget.initialCustomerId;
    _customerName = widget.initialCustomerName;
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

  bool get _needsCustomer =>
      _mode == PosPaymentMode.partial || _mode == PosPaymentMode.credit;

  bool _validateCustomer() {
    if (!_needsCustomer) return true;
    if (_customerId != null && _customerId!.isNotEmpty) return true;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.posCustomerRequired)),
    );
    return false;
  }

  void _pop(PosCheckoutSelection selection) {
    Navigator.pop(context, selection);
  }

  void _confirm() {
    if (_mode == PosPaymentMode.credit) {
      if (!_validateCustomer()) return;
      _pop(
        PosCheckoutSelection.credit(
          customerId: _customerId,
          customerName: _customerName,
          notes: _notes,
          dueDate: _dueDate,
        ),
      );
      return;
    }

    if (!_validateCustomer()) return;

    if (_mode == PosPaymentMode.partial) {
      final cents = _partialCents();
      if (cents == null || cents <= 0 || cents >= widget.totalCents) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.posInvalidPartialAmount)),
        );
        return;
      }
    }

    final account = _selectedAccount;
    if (account == null) {
      if (_mode == PosPaymentMode.partial) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.posSetupPaymentAccount)),
        );
        return;
      }
      _pop(PosCheckoutSelection.cashFallback(notes: _notes));
      return;
    }

    if (_mode == PosPaymentMode.partial) {
      final cents = _partialCents()!;
      _pop(
        PosCheckoutSelection.partial(
          paymentAccountId: account.id,
          paymentAccountName: account.name,
          paidCents: cents,
          customerId: _customerId,
          customerName: _customerName,
          notes: _notes,
          dueDate: _dueDate,
        ),
      );
      return;
    }

    _pop(
      PosCheckoutSelection(
        paymentAccountId: account.id,
        paymentAccountName: account.name,
        mode: PosPaymentMode.full,
        paidCents: widget.totalCents,
        customerId: _customerId,
        customerName: _customerName,
        notes: _notes,
        dueDate: _dueDate,
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (!mounted || picked == null) return;
    setState(() => _dueDate = picked);
  }

  int? _partialCents() {
    final raw = _partialCtrl.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null) return null;
    return (v * 100).round();
  }

  Future<void> _selectCustomer() async {
    final picked = await widget.onPickCustomer();
    if (!mounted || picked == null) return;
    setState(() {
      _customerId = picked.id;
      _customerName = picked.name;
    });
  }

  Future<void> _quickAddCustomer() async {
    final picked = await widget.onQuickAddCustomer();
    if (!mounted || picked == null) return;
    setState(() {
      _customerId = picked.id;
      _customerName = picked.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final remainingCents =
        (widget.totalCents - (_partialCents() ?? 0)).clamp(0, widget.totalCents);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.posCheckout,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.posInvoiceTotal(_totalLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<PosPaymentMode>(
                  segments: const [
                    ButtonSegment(
                      value: PosPaymentMode.full,
                      label: Text('Full'),
                      icon: Icon(Icons.check_circle_outline, size: 18),
                    ),
                    ButtonSegment(
                      value: PosPaymentMode.partial,
                      label: Text('Partial'),
                      icon: Icon(Icons.pie_chart_outline, size: 18),
                    ),
                    ButtonSegment(
                      value: PosPaymentMode.credit,
                      label: Text('Credit'),
                      icon: Icon(Icons.credit_score, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              if (_needsCustomer) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.colCustomer,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '*',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_customerName != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                child: Icon(Icons.person, size: 20),
                              ),
                              title: Text(_customerName!),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => setState(() {
                                  _customerId = null;
                                  _customerName = null;
                                }),
                              ),
                            )
                          else
                            Text(
                              l10n.posCustomerRequiredHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectCustomer,
                                  icon: const Icon(Icons.search, size: 18),
                                  label: Text(l10n.commonSelect),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: _quickAddCustomer,
                                  icon: const Icon(Icons.person_add, size: 18),
                                  label: Text(l10n.posQuickAddShort),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (_customerName != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.posCustomerOptional(_customerName!),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.posNotesOptional,
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ),
              if (_mode == PosPaymentMode.partial) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _partialCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.posAmountReceivedNow,
                      hintText: l10n.posPartialAmountHint,
                      helperText: l10n.posRemainingToDebt(
                        formatMoney(remainingCents, currency: widget.currency),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
              if (_needsCustomer) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Payment due date (optional)'),
                    subtitle: Text(
                      _dueDate != null
                          ? DateFormat.yMMMd().format(_dueDate!)
                          : 'Set a due date for SMS reminders',
                    ),
                    trailing: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setState(() => _dueDate = null),
                          )
                        : null,
                    onTap: _pickDueDate,
                  ),
                ),
              ],
              if (_mode == PosPaymentMode.credit) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.35),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.credit_score_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.posCreditNoPaymentNow(_totalLabel),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _mode == PosPaymentMode.partial
                        ? l10n.posReceivePaymentInto
                        : l10n.posPaymentAccount,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _mode == PosPaymentMode.partial
                          ? 'Set up payment accounts in Accounting before partial sales.'
                          : 'No payment accounts — sale will complete as cash.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
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
                      onChanged: (v) => setState(() => _selectedAccount = v),
                    ),
                  ),
                if (widget.accounts.length >= 2 && _mode == PosPaymentMode.full)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: const Icon(Icons.call_split),
                      title: Text(l10n.posSplitAcrossAccounts),
                      onTap: () =>
                          _pop(PosCheckoutSelection.split(notes: _notes)),
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
                        _mode == PosPaymentMode.credit
                            ? l10n.posCompleteOnCredit
                            : _mode == PosPaymentMode.partial
                                ? l10n.posCompletePartialSale
                                : l10n.posCompleteSale,
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

/// Split tender lines keyed by [PaymentAccount.id].
Future<Map<String, int>?> showPosSplitPaymentDialog(
  BuildContext context,
  WidgetRef ref, {
  required int totalCents,
}) async {
  List<PaymentAccount> accounts;
  try {
    accounts = await _loadPaymentAccounts(ref);
  } catch (_) {
    accounts = [];
  }

  if (!context.mounted) return null;
  if (accounts.length < 2) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.posNeedTwoAccounts)),
    );
    return null;
  }

  final controllers = <String, TextEditingController>{
    for (final a in accounts.take(4)) a.id: TextEditingController(),
  };

  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.posSplitPayment),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.posTotalDue((totalCents / 100).toStringAsFixed(2)),
                style: Theme.of(ctx).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              for (final a in accounts.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controllers[a.id],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: a.name,
                      prefixIcon: Icon(_iconForType(a.accountType)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.commonConfirm),
        ),
      ],
    ),
  );

  final lines = <String, int>{};
  for (final e in controllers.entries) {
    final cents = ((double.tryParse(e.value.text) ?? 0) * 100).round();
    if (cents > 0) lines[e.key] = cents;
    e.value.dispose();
  }

  if (ok != true || lines.isEmpty) return null;
  final sum = lines.values.fold<int>(0, (a, b) => a + b);
  if (sum != totalCents && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Split total ${(sum / 100).toStringAsFixed(2)} '
          'does not match ${(totalCents / 100).toStringAsFixed(2)} — proceeding.',
        ),
      ),
    );
  }
  return lines;
}
