import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../accounting/data/accounting_provider.dart';
import '../../dashboard/dashboard_providers.dart';
import '../../barcode/presentation/barcode_input_field.dart';
import '../../barcode/presentation/barcode_scanner_page.dart';
import '../../barcode/presentation/quick_product_sheet.dart'
    show showQuickProductSheetForPurchase;
import '../domain/purchase_cart_line.dart';
import '../../../ui/layout/app_shell.dart';
import 'purchase_checkout_sheet.dart';

const _uuid = Uuid();

class AddPurchasePage extends ConsumerStatefulWidget {
  const AddPurchasePage({super.key});

  @override
  ConsumerState<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends ConsumerState<AddPurchasePage> {
  final _barcode = TextEditingController();
  final _barcodeFocus = FocusNode();
  final _qty = TextEditingController(text: '1');
  final _cost = TextEditingController();
  final _sell = TextEditingController();
  final _invoice = TextEditingController();
  final _notes = TextEditingController();

  final List<PurchaseCartLine> _cart = [];
  Product? _pendingProduct;
  String? _supplierId;
  String? _supplierName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _barcodeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcode.dispose();
    _barcodeFocus.dispose();
    _qty.dispose();
    _cost.dispose();
    _sell.dispose();
    _invoice.dispose();
    _notes.dispose();
    super.dispose();
  }

  int _toCents(String s) => ((double.tryParse(s.trim()) ?? 0) * 100).round();

  int get _cartTotalCents => _cart.fold(0, (s, l) => s + l.lineTotalCents);

  void _loadPending(Product product) {
    setState(() {
      _pendingProduct = product;
      _cost.text = (product.purchasePriceCents / 100).toStringAsFixed(2);
      _sell.text = (product.sellingPriceCents / 100).toStringAsFixed(2);
      _qty.text = '1';
    });
  }

  void _addToCart(Product product, {int? quantity}) {
    final qty = quantity ?? int.tryParse(_qty.text.trim()) ?? 1;
    if (qty <= 0) return;
    final costCents = _cost.text.trim().isEmpty
        ? product.purchasePriceCents
        : _toCents(_cost.text);
    final sellCents =
        _sell.text.trim().isEmpty ? null : _toCents(_sell.text);

    final idx = _cart.indexWhere((l) => l.productId == product.id);
    setState(() {
      if (idx == -1) {
        _cart.add(
          PurchaseCartLine(
            productId: product.id,
            name: product.name,
            barcode: product.barcode,
            quantity: qty,
            costCents: costCents,
            stockQty: product.quantity,
            catalogSellCents: product.sellingPriceCents,
            newSellCents: sellCents,
          ),
        );
      } else {
        _cart[idx] = _cart[idx].copyWith(
          quantity: _cart[idx].quantity + qty,
          costCents: costCents,
          newSellCents: sellCents ?? _cart[idx].newSellCents,
        );
      }
      _pendingProduct = null;
      _barcode.clear();
      _qty.text = '1';
      _cost.clear();
      _sell.clear();
    });
    _barcodeFocus.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.purchaseAddedProduct(product.name))),
    );
  }

  Future<void> _resolveBarcode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      await _openNewProductSheet();
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final product = await db.findProductByBarcode(
      storeId: StoreContext.storeId,
      barcode: trimmed,
    );

    if (!mounted) return;

    if (product != null) {
      _loadPending(product);
      return;
    }

    await _openNewProductSheet(barcode: trimmed);
  }

  Future<void> _openNewProductSheet({String? barcode}) async {
    final created = await showQuickProductSheetForPurchase(
      context,
      barcode: barcode,
    );
    if (!mounted || created == null) return;
    _cost.text = (created.product.purchasePriceCents / 100).toStringAsFixed(2);
    _sell.text = (created.product.sellingPriceCents / 100).toStringAsFixed(2);
    _qty.text = created.receiveQty.toString();
    _addToCart(created.product, quantity: created.receiveQty);
  }

  Future<void> _pickSupplier() async {
    final db = ref.read(appDatabaseProvider);
    final suppliers =
        await db.watchSuppliers(storeId: StoreContext.storeId).first;
    if (!mounted) return;

    final l10n = context.l10n;
    final picked = await showModalBottomSheet<Supplier?>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_business),
              title: Text(l10n.quickAddSupplier),
              onTap: () {
                Navigator.pop(ctx);
                _quickAddSupplier();
              },
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: suppliers
                    .map(
                      (s) => ListTile(
                        leading: const Icon(Icons.local_shipping_outlined),
                        title: Text(s.name),
                        subtitle: s.phone != null ? Text(s.phone!) : null,
                        onTap: () => Navigator.pop(ctx, s),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _supplierId = picked.id;
        _supplierName = picked.name;
      });
    }
  }

  Future<void> _quickAddSupplier() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.quickAddSupplier),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: '${l10n.commonName} *'),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phone,
                decoration: InputDecoration(labelText: l10n.commonPhone),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: address,
                decoration: InputDecoration(labelText: l10n.settingsAddress),
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
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    final supplierName = name.text.trim();
    final phoneVal = phone.text.trim();
    final addressVal = address.text.trim();
    name.dispose();
    phone.dispose();
    address.dispose();

    if (ok != true || supplierName.isEmpty) return;

    final db = ref.read(appDatabaseProvider);
    final existing = await db.findSupplierByNameOrPhone(
      storeId: StoreContext.storeId,
      name: supplierName,
      phone: phoneVal.isEmpty ? null : phoneVal,
    );
    if (existing != null) {
      setState(() {
        _supplierId = existing.id;
        _supplierName = existing.name;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.purchaseUsingSupplier(existing.name),
            ),
          ),
        );
      }
      return;
    }

    final id = await db.getOrCreateSupplier(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      name: supplierName,
      phone: phoneVal.isEmpty ? null : phoneVal,
      address: addressVal.isEmpty ? null : addressVal,
    );
    setState(() {
      _supplierId = id;
      _supplierName = supplierName;
    });
  }

  Future<void> _completePurchase() async {
    if (_cart.isEmpty) return;
    if (_supplierId == null || _supplierName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.purchaseSelectSupplierFirst)),
      );
      return;
    }

    final currency =
        ref.read(storeSettingsProvider).value?.currencyCode ?? 'USD';

    final payment = await showPurchaseCheckoutSheet(
      context,
      ref,
      totalCents: _cartTotalCents,
      initialNotes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.purchaseNotSavedCancelled)),
      );
      return;
    }

    if (!payment.isCredit && payment.paymentAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.purchaseSelectPaymentAccount)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final tenantId = StoreContext.tenantId;
      final storeId = StoreContext.storeId;
      final total = _cartTotalCents;

      final paidCents = payment.isCredit
          ? 0
          : (payment.paidCents ?? total);
      final paymentStatus = payment.isCredit
          ? 'unpaid'
          : (paidCents >= total
              ? 'paid'
              : (paidCents > 0 ? 'partially_paid' : 'unpaid'));

      final purchaseId = _uuid.v4();
      await db.createPurchase(
        purchase: PurchasesCompanion.insert(
          id: purchaseId,
          tenantId: tenantId,
          storeId: storeId,
          supplierId: _supplierId!,
          invoiceNumber: drift.Value(
            _invoice.text.trim().isEmpty ? null : _invoice.text.trim(),
          ),
          purchaseDate: DateTime.now(),
          totalCents: total,
          paidCents: drift.Value(paidCents),
          paymentStatus: drift.Value(paymentStatus),
          notes: drift.Value(
            (payment.notes ?? _notes.text.trim()).isEmpty
                ? null
                : (payment.notes ?? _notes.text.trim()),
          ),
        ),
        items: _cart
            .map(
              (l) => PurchaseItemsCompanion.insert(
                id: _uuid.v4(),
                tenantId: tenantId,
                storeId: storeId,
                purchaseId: purchaseId,
                productId: l.productId,
                quantity: l.quantity,
                purchasePriceCents: l.costCents,
                lineTotalCents: l.lineTotalCents,
                newSellingPriceCents: drift.Value(l.newSellCents),
              ),
            )
            .toList(),
      );

      final saved = await db.getPurchaseById(
        storeId: storeId,
        purchaseId: purchaseId,
      );
      if (saved != null) {
        try {
          await ref.read(accountingEngineProvider).postPurchase(
                purchase: saved,
                paymentAccountId:
                    paidCents > 0 ? payment.paymentAccountId : null,
              );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Purchase saved but accounting entry failed: $e',
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        invalidateDashboardMetrics(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.purchaseSavedSummary(
                formatMoney(total, currency: currency),
                paymentStatus.replaceAll('_', ' '),
              ),
            ),
          ),
        );
        setState(() {
          _cart.clear();
          _pendingProduct = null;
          _invoice.clear();
          _notes.clear();
        });
        _barcodeFocus.requestFocus();
      }
    } catch (e, st) {
      debugPrint('Purchase save failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.purchaseCouldNotSave(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currency =
        ref.watch(storeSettingsProvider).value?.currencyCode ?? 'USD';
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final leftColumn = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.navSupplier, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickSupplier,
            icon: const Icon(Icons.local_shipping_outlined),
            label: Text(
              _supplierName ?? l10n.selectOrAddSupplier,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.navProducts, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          BarcodeInputField(
            controller: _barcode,
            focusNode: _barcodeFocus,
            autofocus: true,
            label: '${l10n.barcodeLabel} (${l10n.commonOptional})',
            onSubmitted: _resolveBarcode,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: l10n.commonScan,
                onPressed: () async {
                  final code = await scanBarcodeWithCamera(context);
                  if (code != null) await _resolveBarcode(code);
                },
                icon: const Icon(Icons.qr_code_scanner),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _barcode,
                  builder: (context, value, _) {
                    return FilledButton(
                      onPressed: () => _resolveBarcode(value.text),
                      child: Text(
                        value.text.trim().isEmpty
                            ? l10n.addProduct
                            : l10n.purchaseLookUp,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_pendingProduct != null) ...[
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pendingProduct!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_pendingProduct!.barcode != null)
                      Text(
                        '${l10n.barcodeLabel}: ${_pendingProduct!.barcode}',
                      ),
                    Text(
                      l10n.purchaseInStockLine(
                        _pendingProduct!.quantity,
                        formatMoney(
                          _pendingProduct!.purchasePriceCents,
                          currency: currency,
                        ),
                        formatMoney(
                          _pendingProduct!.sellingPriceCents,
                          currency: currency,
                        ),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _qty,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.commonQuantity,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _cost,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.purchasePrice,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sell,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.newSellPriceOptional,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _addToCart(_pendingProduct!),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l10n.posAddToCart),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _invoice,
            decoration: InputDecoration(
              labelText: l10n.invoiceOptional,
              isDense: true,
            ),
          ),
        ],
      ),
    );

    final cartPanel = Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.purchaseCart,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cart.isEmpty
                  ? Center(
                      child: Text(
                        l10n.purchaseCartEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final l = _cart[i];
                        final margin = l.marginPercent;
                        return Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: Text(
                                    l.name.isNotEmpty
                                        ? l.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (l.barcode != null)
                                        Text(
                                          l.barcode!,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.purchaseStockLine(
                                          l.stockQty,
                                          l.quantity,
                                        ),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        '${l10n.purchasePrice}: ${formatMoney(l.costCents, currency: currency)} • '
                                        '${formatMoney(l.sellCents, currency: currency)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      if (margin != null)
                                        Text(
                                          l10n.purchaseMargin(
                                            (margin * 100).toStringAsFixed(0),
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: margin >= 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(
                                        l.lineTotalCents,
                                        currency: currency,
                                      ),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () =>
                                          setState(() => _cart.removeAt(i)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Row(
              children: [
                Text(l10n.commonTotal, style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  formatMoney(_cartTotalCents, currency: currency),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: InventraXTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving || _cart.isEmpty ? null : _completePurchase,
              style: FilledButton.styleFrom(
                backgroundColor: InventraXTheme.accent,
                minimumSize: const Size.fromHeight(52),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_saving ? l10n.saving : l10n.completePurchase),
            ),
          ],
        ),
      ),
    );

    return AppShell(
      route: '/purchases/add',
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: leftColumn),
                Expanded(child: cartPanel),
              ],
            )
          : Column(
              children: [
                SizedBox(height: 320, child: leftColumn),
                Expanded(child: cartPanel),
              ],
            ),
    );
  }
}
