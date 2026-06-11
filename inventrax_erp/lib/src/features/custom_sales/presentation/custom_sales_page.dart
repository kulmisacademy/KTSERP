import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/design_system.dart';
import '../../../core/store_context.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../sync/sync_service.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../../pos/domain/pos_tax.dart';
import '../../pos/presentation/pos_checkout_sheet.dart';
import '../../sales/domain/invoice_discount.dart';
import '../../sales/domain/invoice_totals_engine.dart';
import '../../sales/presentation/widgets/sale_invoice_modal.dart';
import '../application/custom_sales_controller.dart';
import '../application/custom_sales_totals_provider.dart';
import '../domain/custom_sales_models.dart';
import 'custom_sales_invoice_preview.dart';
import 'widgets/custom_sales_items_table.dart';
import 'widgets/custom_sales_product_search.dart';

const _uuid = Uuid();

class CustomSalesPage extends ConsumerStatefulWidget {
  const CustomSalesPage({super.key});

  @override
  ConsumerState<CustomSalesPage> createState() => _CustomSalesPageState();
}

class _CustomSalesPageState extends ConsumerState<CustomSalesPage> {
  final _invoiceRef = TextEditingController();
  final _notes = TextEditingController();
  final _walkInName = TextEditingController();
  final _walkInPhone = TextEditingController();
  final _walkInEmail = TextEditingController();
  final _walkInAddress = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _invoiceRef.dispose();
    _notes.dispose();
    _walkInName.dispose();
    _walkInPhone.dispose();
    _walkInEmail.dispose();
    _walkInAddress.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final db = ref.read(appDatabaseProvider);
    final customers = await db
        .watchCustomers(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
        )
        .first;
    if (!mounted) return;

    final picked = await showModalBottomSheet<Customer?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Add new customer'),
              onTap: () async {
                Navigator.pop(ctx);
                await _quickAddCustomer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Walk-in customer'),
              onTap: () => Navigator.pop(ctx),
            ),
            for (final c in customers)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name),
                subtitle: Text(c.phone ?? c.email ?? ''),
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );

    if (picked != null) {
      _applyCustomer(picked);
    }
  }

  void _applyCustomer(Customer customer) {
    ref.read(customSalesControllerProvider.notifier).setCustomer(
          id: customer.id,
          name: customer.name,
          phone: customer.phone,
          email: customer.email,
          address: customer.address,
        );
    _walkInName.text = customer.name;
    _walkInPhone.text = customer.phone ?? '';
    _walkInEmail.text = customer.email ?? '';
    _walkInAddress.text = customer.address ?? '';
  }

  Future<({String id, String name})?> _quickAddCustomer() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final email = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add new customer'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final customerName = name.text.trim();
    final phoneVal = phone.text.trim();
    final emailVal = email.text.trim();
    name.dispose();
    phone.dispose();
    email.dispose();

    if (ok != true || customerName.isEmpty) return null;

    final db = ref.read(appDatabaseProvider);
    final id = _uuid.v4();
    await db.addCustomer(
      CustomersCompanion.insert(
        id: id,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        name: customerName,
        phone: drift.Value(phoneVal.isEmpty ? null : phoneVal),
        email: drift.Value(emailVal.isEmpty ? null : emailVal),
      ),
    );

    if (!mounted) return null;

    final saved = await db.getCustomerById(
      storeId: StoreContext.storeId,
      customerId: id,
    );
    if (saved != null) {
      _applyCustomer(saved);
    } else {
      ref.read(customSalesControllerProvider.notifier).setCustomer(
            id: id,
            name: customerName,
            phone: phoneVal.isEmpty ? null : phoneVal,
            email: emailVal.isEmpty ? null : emailVal,
          );
      _walkInName.text = customerName;
      _walkInPhone.text = phoneVal;
      _walkInEmail.text = emailVal;
    }

    return (id: id, name: customerName);
  }

  Future<void> _previewInvoice() async {
    final state = ref.read(customSalesControllerProvider);
    if (state.lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to preview')),
      );
      return;
    }
    await showCustomSalesInvoicePreview(context, ref, state);
  }

  Future<void> _checkout() async {
    final state = ref.read(customSalesControllerProvider);
    if (state.lines.isEmpty) return;

    if (state.hasStockIssues) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Stock warning'),
          content: const Text(
            'Some items exceed available stock. Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final totals = ref.read(customSalesTotalsProvider);
    final total = totals.grandTotalCents;

    final choice = await showPosCheckoutSheet(
      context,
      ref,
      totalCents: total,
      customerId: state.customerId,
      customerName: state.customerName,
      initialNotes: state.notes,
      onPickCustomer: () async {
        await _pickCustomer();
        final s = ref.read(customSalesControllerProvider);
        if (s.customerId == null) return null;
        return (id: s.customerId!, name: s.customerName ?? '');
      },
      onQuickAddCustomer: () async {
        final c = await _quickAddCustomer();
        if (c == null) return null;
        ref.read(customSalesControllerProvider.notifier).setCustomer(
              id: c.id,
              name: c.name,
            );
        return c;
      },
    );
    if (choice == null || !mounted) return;

    Map<String, int>? split;
    if (choice.isSplit) {
      split = await showPosSplitPaymentDialog(context, ref, totalCents: total);
      if (split == null) return;
    }

    setState(() => _saving = true);
    try {
      final result = await ref.read(customSalesControllerProvider.notifier).checkout(
            method: choice.isSplit
                ? 'split'
                : (choice.isCredit ? 'credit' : choice.paymentAccountName),
            paidCents: choice.paidCents,
            splitPayments: split,
            paymentAccountId: choice.paymentAccountId,
            paymentAccountName: choice.paymentAccountName,
            isCredit: choice.isCredit,
            customerId: choice.customerId ?? state.customerId,
            customerName: choice.customerName ?? state.customerName,
            dueDate: choice.dueDate,
          );

      if (result == null || !mounted) return;

      if (SupabaseConfig.isConfigured) {
        await ref.read(syncWorkerProvider.notifier).pushNow();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale completed — ${result.paymentSummary}')),
      );

      await showSaleInvoiceModal(context, ref, result.saleId);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveDraft() async {
    await ref.read(customSalesControllerProvider.notifier).saveDraft();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved')),
      );
    }
  }

  void _syncWalkInFields() {
    ref.read(customSalesControllerProvider.notifier).setWalkInCustomer(
          name: _walkInName.text,
          phone: _walkInPhone.text,
          email: _walkInEmail.text,
          address: _walkInAddress.text,
        );
  }

  void _hydrateFromState(CustomSalesState state) {
    if (_invoiceRef.text != (state.invoiceReference ?? '')) {
      _invoiceRef.text = state.invoiceReference ?? '';
    }
    if (_notes.text != (state.notes ?? '')) {
      _notes.text = state.notes ?? '';
    }
    if (_walkInName.text != (state.customerName ?? '')) {
      _walkInName.text = state.customerName ?? '';
    }
    if (_walkInPhone.text != (state.customerPhone ?? '')) {
      _walkInPhone.text = state.customerPhone ?? '';
    }
    if (_walkInEmail.text != (state.customerEmail ?? '')) {
      _walkInEmail.text = state.customerEmail ?? '';
    }
    if (_walkInAddress.text != (state.customerAddress ?? '')) {
      _walkInAddress.text = state.customerAddress ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customSalesControllerProvider);
    ref.listen(customSalesControllerProvider, (prev, next) {
      final restored = prev != null &&
          prev.lines.isEmpty &&
          next.lines.isNotEmpty;
      if (restored ||
          prev?.draftId != next.draftId ||
          (prev?.lines.isEmpty == true && next.lines.isNotEmpty)) {
        _hydrateFromState(next);
      }
    });
    final totals = ref.watch(customSalesTotalsProvider);
    final tax = ref.watch(posTaxProvider);
    final currency = ref.watch(storeCurrencyProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 1000;

    return AppShell(
      route: '/sales/custom',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Sales',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Build professional invoices with custom pricing',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (state.lines.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(customSalesControllerProvider.notifier).clear();
                      _invoiceRef.clear();
                      _notes.clear();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _BuilderPanel(
                          invoiceRef: _invoiceRef,
                          notes: _notes,
                          walkInName: _walkInName,
                          walkInPhone: _walkInPhone,
                          walkInEmail: _walkInEmail,
                          walkInAddress: _walkInAddress,
                          onPickCustomer: _pickCustomer,
                          onWalkInChanged: _syncWalkInFields,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 320,
                        child: _TotalsPanel(
                          state: state,
                          totals: totals,
                          tax: tax,
                          currency: currency,
                          saving: _saving,
                          onPreview: _previewInvoice,
                          onSaveDraft: _saveDraft,
                          onCheckout: _checkout,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _BuilderPanel(
                        invoiceRef: _invoiceRef,
                        notes: _notes,
                        walkInName: _walkInName,
                        walkInPhone: _walkInPhone,
                        walkInEmail: _walkInEmail,
                        walkInAddress: _walkInAddress,
                        onPickCustomer: _pickCustomer,
                        onWalkInChanged: _syncWalkInFields,
                      ),
                      const SizedBox(height: 16),
                      _TotalsPanel(
                        state: state,
                        totals: totals,
                        tax: tax,
                        currency: currency,
                        saving: _saving,
                        onPreview: _previewInvoice,
                        onSaveDraft: _saveDraft,
                        onCheckout: _checkout,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BuilderPanel extends ConsumerWidget {
  const _BuilderPanel({
    required this.invoiceRef,
    required this.notes,
    required this.walkInName,
    required this.walkInPhone,
    required this.walkInEmail,
    required this.walkInAddress,
    required this.onPickCustomer,
    required this.onWalkInChanged,
  });

  final TextEditingController invoiceRef;
  final TextEditingController notes;
  final TextEditingController walkInName;
  final TextEditingController walkInPhone;
  final TextEditingController walkInEmail;
  final TextEditingController walkInAddress;
  final VoidCallback onPickCustomer;
  final VoidCallback onWalkInChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSalesControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Customer', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onPickCustomer,
                icon: const Icon(Icons.person_search_outlined),
                label: Text(
                  state.customerName ?? 'Select or enter customer',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: walkInName,
                decoration: const InputDecoration(
                  labelText: 'Customer name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                onChanged: (_) => onWalkInChanged(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: walkInPhone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                onChanged: (_) => onWalkInChanged(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: walkInEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onChanged: (_) => onWalkInChanged(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: walkInAddress,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
                onChanged: (_) => onWalkInChanged(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Invoice details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: invoiceRef,
                decoration: const InputDecoration(
                  labelText: 'Invoice reference (optional)',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
                onChanged: (v) => ref
                    .read(customSalesControllerProvider.notifier)
                    .setInvoiceReference(v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
                onChanged: (v) => ref
                    .read(customSalesControllerProvider.notifier)
                    .setNotes(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              const CustomSalesProductSearch(),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _addManualLine(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add manual line'),
                ),
              ),
              const SizedBox(height: 12),
              const CustomSalesItemsTable(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addManualLine(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final price = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual line item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Description'),
              autofocus: true,
            ),
            TextField(
              controller: price,
              decoration: const InputDecoration(labelText: 'Unit price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      final cents = ((double.tryParse(price.text) ?? 0) * 100).round();
      ref.read(customSalesControllerProvider.notifier).addManualLine(
            name: name.text.trim(),
            unitPriceCents: cents,
          );
    }
  }
}

class _TotalsPanel extends ConsumerStatefulWidget {
  const _TotalsPanel({
    required this.state,
    required this.totals,
    required this.tax,
    required this.currency,
    required this.saving,
    required this.onPreview,
    required this.onSaveDraft,
    required this.onCheckout,
  });

  final CustomSalesState state;
  final InvoiceTotalsBreakdown totals;
  final PosTaxCalculator tax;
  final String currency;
  final bool saving;
  final VoidCallback onPreview;
  final VoidCallback onSaveDraft;
  final VoidCallback onCheckout;

  @override
  ConsumerState<_TotalsPanel> createState() => _TotalsPanelState();
}

class _TotalsPanelState extends ConsumerState<_TotalsPanel> {
  late TextEditingController _discValue;
  DiscountKind _discKind = DiscountKind.fixedCents;

  @override
  void initState() {
    super.initState();
    _discValue = TextEditingController();
    _syncDiscountFields(widget.state.invoiceDiscount);
  }

  @override
  void didUpdateWidget(_TotalsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.invoiceDiscount != widget.state.invoiceDiscount) {
      _syncDiscountFields(widget.state.invoiceDiscount);
    }
  }

  void _syncDiscountFields(InvoiceDiscount d) {
    _discKind = d.kind == DiscountKind.none ? DiscountKind.fixedCents : d.kind;
    _discValue.text = !d.isActive
        ? ''
        : d.kind == DiscountKind.percentBps
            ? (d.value / 100).toStringAsFixed(1)
            : (d.value / 100).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _discValue.dispose();
    super.dispose();
  }

  void _applyInvoiceDiscount() {
    final raw = double.tryParse(_discValue.text) ?? 0;
    if (raw <= 0) {
      ref.read(customSalesControllerProvider.notifier).setInvoiceDiscount(
            InvoiceDiscount.none,
          );
      return;
    }
    if (_discKind == DiscountKind.percentBps) {
      ref.read(customSalesControllerProvider.notifier).setInvoiceDiscount(
            InvoiceDiscount(
              kind: DiscountKind.percentBps,
              value: (raw * 100).round(),
            ),
          );
    } else {
      ref.read(customSalesControllerProvider.notifier).setInvoiceDiscount(
            InvoiceDiscount(
              kind: DiscountKind.fixedCents,
              value: (raw * 100).round(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.totals;
    final tax = widget.tax;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Totals', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _totalRow('Subtotal', t.itemsSubtotalCents, widget.currency),
          if (t.showLineDiscounts)
            _totalRow('Item discounts', -t.lineDiscountsCents, widget.currency),
          if (t.showInvoiceDiscount)
            _totalRow('Invoice discount', -t.invoiceDiscountCents, widget.currency),
          if (t.showTax)
            _totalRow(tax.taxName ?? 'Tax', t.taxCents, widget.currency),
          const Divider(),
          _totalRow('Grand total', t.grandTotalCents, widget.currency, bold: true),
          const SizedBox(height: 16),
          Text('Invoice discount', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<DiscountKind>(
                value: _discKind,
                items: const [
                  DropdownMenuItem(
                    value: DiscountKind.fixedCents,
                    child: Text('Fixed'),
                  ),
                  DropdownMenuItem(
                    value: DiscountKind.percentBps,
                    child: Text('Percent'),
                  ),
                ],
                onChanged: (k) {
                  if (k == null) return;
                  setState(() => _discKind = k);
                  _applyInvoiceDiscount();
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _discValue,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: _discKind == DiscountKind.percentBps ? '10' : '0.00',
                    suffixText: _discKind == DiscountKind.percentBps ? '%' : widget.currency,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSubmitted: (_) => _applyInvoiceDiscount(),
                  onEditingComplete: _applyInvoiceDiscount,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Apply tax'),
            subtitle: tax.hasTax
                ? Text(tax.taxName ?? 'Store tax rate')
                : const Text('No tax configured in settings'),
            value: widget.state.taxEnabled && tax.hasTax,
            onChanged: tax.hasTax
                ? (v) => ref
                    .read(customSalesControllerProvider.notifier)
                    .setTaxEnabled(v)
                : null,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.state.lines.isEmpty ? null : widget.onPreview,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview invoice'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.state.lines.isEmpty ? null : widget.onSaveDraft,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save draft'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: widget.state.lines.isEmpty || widget.saving
                ? null
                : widget.onCheckout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: widget.saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.payments_outlined),
            label: Text(widget.saving ? 'Processing…' : 'Checkout & complete'),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, int cents, String currency, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
          Text(
            formatMoney(cents.abs(), currency: currency),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 18 : 14,
              color: bold ? AppColors.accent : null,
            ),
          ),
        ],
      ),
    );
  }
}
