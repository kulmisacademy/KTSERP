import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/design_system.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../ui/layout/app_shell.dart';
import '../../barcode/presentation/barcode_lookup.dart';
import '../../barcode/presentation/barcode_scanner_page.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../sync/sync_service.dart';
import '../domain/pos_models.dart';
import '../domain/pos_state.dart';
import '../domain/pos_tax.dart';
import 'pos_checkout_sheet.dart';
import 'pos_controller.dart';
import 'pos_products_provider.dart';
import 'pos_receipt.dart';
import 'widgets/pos_product_catalog.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  final _barcodeFocus = FocusNode();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _barcodeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  void _openMobileCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: AppRadius.sheetTop,
          ),
          child: _PosCartPanel(
            scrollController: scrollController,
            onCheckout: () => _showCheckout(context),
            onHold: _holdSale,
            onCustomer: _pickCustomer,
          ),
        ),
      ),
    );
  }

  Future<void> _submitBarcode() async {
    final raw = _searchController.text;
    if (raw.trim().isEmpty) return;

    final product = await barcodeLookup(ref).resolve(
      context,
      rawBarcode: raw,
      allowDirectSale: true,
      onDirectSale: (_) => _showDirectSale(context),
    );

    if (!mounted) return;
    if (product != null) {
      ref.read(posControllerProvider.notifier).addProductFromLookup(product);
      HapticFeedback.mediumImpact();
      showPosScanFlash(context, product.name);
    }
    _searchController.clear();
    _barcodeFocus.requestFocus();
  }

  Future<void> _openCameraScan() async {
    final code = await scanBarcodeWithCamera(context);
    if (code == null || !mounted) return;
    _searchController.text = code;
    await _submitBarcode();
  }

  Future<void> _showDirectSale(BuildContext context) async {
    final l10n = context.l10n;
    final name = TextEditingController();
    final price = TextEditingController();
    final qty = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.posDirectSale),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.posItemName),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.commonPrice),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.commonQuantity),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.posAddToCart)),
        ],
      ),
    );
    if (ok == true && name.text.trim().isNotEmpty) {
      final priceCents =
          ((double.tryParse(price.text) ?? 0) * 100).round();
      ref.read(posControllerProvider.notifier).addDirectSaleItem(
            name: name.text.trim(),
            priceCents: priceCents,
            quantity: int.tryParse(qty.text.trim()) ?? 1,
          );
    }
    name.dispose();
    price.dispose();
    qty.dispose();
  }

  Future<void> _showCheckout(BuildContext context) async {
    final l10n = context.l10n;
    final state = ref.read(posControllerProvider);
    if (state.cart.isEmpty) return;

    final tax = ref.read(posTaxProvider);
    PosCheckoutSelection? choice;
    try {
      choice = await showPosCheckoutSheet(
        context,
        ref,
        totalCents: state.totalCents(tax),
        customerId: state.customerId,
        customerName: state.customerName,
        initialNotes: state.notes,
        onPickCustomer: _pickCustomerForCheckout,
        onQuickAddCustomer: _quickAddCustomerForCheckout,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.posCheckoutError(e.toString()))),
        );
      }
      return;
    }
    if (choice == null) return;

    final notifier = ref.read(posControllerProvider.notifier);
    final checkoutCustomerId = choice.customerId ?? state.customerId;
    final checkoutCustomerName = choice.customerName ?? state.customerName;
    if (choice.notes != null) {
      notifier.setNotes(choice.notes);
    }

    Map<String, int>? split;
    if (choice.isSplit) {
      split = await showPosSplitPaymentDialog(
        context,
        ref,
        totalCents: state.totalCents(tax),
      );
      if (split == null) return;
    }

    ({String saleId, PosState snapshot, String paymentSummary})? result;
    try {
      result = await ref.read(posControllerProvider.notifier).checkout(
            method: choice.isSplit
                ? 'split'
                : (choice.isCredit
                    ? 'credit'
                    : (choice.mode == PosPaymentMode.partial
                        ? 'partial'
                        : 'cash')),
            paidCents: choice.isCredit
                ? 0
                : (choice.paidCents ??
                    (choice.isSplit ? null : state.totalCents(tax))),
            splitPayments: split,
            paymentAccountId: choice.paymentAccountId,
            paymentAccountName: choice.paymentAccountName,
            isCredit: choice.isCredit,
            customerId: checkoutCustomerId,
            customerName: checkoutCustomerName,
            dueDate: choice.dueDate,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyError(e, l10n: l10n))),
        );
      }
      return;
    }
    if (!mounted || result == null) return;
    final completed = result;

    final settings = ref.read(storeSettingsProvider).value;
    var shouldPrint = settings?.autoPrintReceipt ?? false;
    if (!shouldPrint) {
      final printReceipt = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.posSaleComplete),
          content: Text(
            '${l10n.commonTotal}: ${formatMoney(completed.snapshot.totalCents(tax), currency: settings?.currencyCode ?? 'USD')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonDone),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.posPrintReceipt),
            ),
          ],
        ),
      );
      shouldPrint = printReceipt == true;
    }
    if (shouldPrint && mounted) {
      await printSaleReceipt(
        settings: settings,
        cartState: completed.snapshot,
        paymentSummary: completed.paymentSummary,
        saleId: completed.saleId,
      );
    }
    if (SupabaseConfig.isConfigured) {
      unawaited(ref.read(syncWorkerProvider.notifier).pushNow());
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.posSaleCompletedSummary(completed.paymentSummary),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _holdSale() async {
    final l10n = context.l10n;
    final state = ref.read(posControllerProvider);
    if (state.cart.isEmpty) return;
    final label = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.posHoldSale),
        content: TextField(
          controller: label,
          decoration: InputDecoration(
            labelText: l10n.posLabelOptional,
            hintText: l10n.posLabelHint,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.posHold)),
        ],
      ),
    );
    final labelText = label.text.trim();
    label.dispose();
    if (ok == true) {
      await ref.read(posControllerProvider.notifier).holdCurrentSale(
            label: labelText.isEmpty ? null : labelText,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.posSaleHeld)),
        );
      }
    }
  }

  Future<({String id, String name})?> _pickCustomerForCheckout() async {
    final db = ref.read(appDatabaseProvider);
    final customers =
        await db
            .watchCustomers(
              tenantId: StoreContext.tenantId,
              storeId: StoreContext.storeId,
            )
            .first;
    if (!mounted) return null;

    final picked = await showModalBottomSheet<Customer?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...customers.map(
              (c) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name),
                subtitle: c.phone != null ? Text(c.phone!) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return null;
    return (id: picked.id, name: picked.name);
  }

  Future<({String id, String name})?> _quickAddCustomerForCheckout() async {
    final l10n = context.l10n;
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.posQuickAddCustomer),
        content: Column(
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
          ],
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
    final customerName = name.text.trim();
    final phoneVal = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (ok != true || customerName.isEmpty) return null;

    final db = ref.read(appDatabaseProvider);
    final id = const Uuid().v4();
    await db.addCustomer(
      CustomersCompanion.insert(
        id: id,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        name: customerName,
        phone: drift.Value(phoneVal.isEmpty ? null : phoneVal),
      ),
    );
    return (id: id, name: customerName);
  }

  Future<void> _pickCustomer() async {
    final l10n = context.l10n;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: Text(l10n.posQuickAddCustomer),
              onTap: () async {
                Navigator.pop(ctx);
                await _quickAddCustomer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off_outlined),
              title: Text(l10n.posNoCustomer),
              onTap: () => Navigator.pop(ctx, null),
            ),
            ...customers.map(
              (c) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(c.name),
                subtitle: c.phone != null ? Text(c.phone!) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            ),
          ],
        ),
      ),
    );

    final controller = ref.read(posControllerProvider.notifier);
    if (!mounted) return;
    if (picked == null) {
      controller.setCustomer();
    } else {
      controller.setCustomer(id: picked.id, name: picked.name);
    }
  }

  Future<void> _quickAddCustomer() async {
    final l10n = context.l10n;
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.posNewCustomer),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    final customerName = name.text.trim();
    final phoneVal = phone.text.trim();
    name.dispose();
    phone.dispose();
    if (ok != true || customerName.isEmpty) return;

    final id = const Uuid().v4();
    await ref.read(appDatabaseProvider).addCustomer(
          CustomersCompanion.insert(
            id: id,
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            name: customerName,
            phone: drift.Value(phoneVal.isEmpty ? null : phoneVal),
          ),
        );
    ref.read(posControllerProvider.notifier).setCustomer(
          id: id,
          name: customerName,
        );
  }

  Future<void> _showHeldSales() async {
    final l10n = context.l10n;
    final held = ref.read(heldSalesProvider).value ?? [];
    if (held.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.posNoHeldSales)),
        );
      }
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: held
              .map(
                (h) => ListTile(
                  leading: const Icon(Icons.pause_circle_outline),
                  title: Text(h.label ?? l10n.posHeldSaleLabel),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(h.createdAt),
                  ),
                  onTap: () => Navigator.pop(ctx, h.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(posControllerProvider.notifier)
                          .discardHeldSale(h.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked == null) return;
    final restored =
        await ref.read(posControllerProvider.notifier).restoreHeldSale(picked);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored ? l10n.posHeldRestored : l10n.posClearCartFirst,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(posControllerProvider);
    final tax = ref.watch(posTaxProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1024;
    final l10n = context.l10n;

    return AppShell(
      route: '/pos',
      fullBleed: true,
      actions: [
        IconButton(
          tooltip: l10n.posHeldSales,
          onPressed: _showHeldSales,
          icon: Badge(
            isLabelVisible: (ref.watch(heldSalesProvider).value?.length ?? 0) > 0,
            label: Text('${ref.watch(heldSalesProvider).value?.length ?? 0}'),
            child: const Icon(Icons.pause_circle_outline),
          ),
        ),
        if (!isWide)
          TextButton.icon(
            onPressed: _openMobileCart,
            icon: Badge(
              label: Text('${state.cart.length}'),
              isLabelVisible: state.cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: Text(
              (state.totalCents(tax) / 100).toStringAsFixed(2),
            ),
          ),
      ],
      child: Stack(
        children: [
          Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.f1): _FocusSearchIntent(),
          SingleActivator(LogicalKeyboardKey.f2): _DirectSaleIntent(),
          SingleActivator(LogicalKeyboardKey.f10): _CheckoutIntent(),
          SingleActivator(LogicalKeyboardKey.keyH, control: true): _HoldSaleIntent(),
        },
        child: Actions(
          actions: {
            _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
              onInvoke: (_) {
                _barcodeFocus.requestFocus();
                return null;
              },
            ),
            _DirectSaleIntent: CallbackAction<_DirectSaleIntent>(
              onInvoke: (_) {
                _showDirectSale(context);
                return null;
              },
            ),
            _CheckoutIntent: CallbackAction<_CheckoutIntent>(
              onInvoke: (_) async {
                if (state.cart.isNotEmpty) await _showCheckout(context);
                return null;
              },
            ),
            _HoldSaleIntent: CallbackAction<_HoldSaleIntent>(
              onInvoke: (_) {
                _holdSale();
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _PosSearchBar(
                    controller: _searchController,
                    focusNode: _barcodeFocus,
                    onChanged: (v) =>
                        ref.read(posSearchProvider.notifier).set(v),
                    onSubmitted: (_) => _submitBarcode(),
                    onCameraScan: _openCameraScan,
                    onQuickAdd: () => _showQuickAdd(context),
                  ),
                ),
                Expanded(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: PosProductCatalog(
                                  onProductTap: (p) {
                                    ref
                                        .read(posControllerProvider.notifier)
                                        .addProductToCart(p);
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 380,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: _PosCartPanel(
                                  onCheckout: () => _showCheckout(context),
                                  onHold: _holdSale,
                                  onCustomer: _pickCustomer,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PosProductCatalog(
                            onProductTap: (p) {
                              ref
                                  .read(posControllerProvider.notifier)
                                  .addProductToCart(p);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                ),
                if (!isWide)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openMobileCart,
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: Text(
                                l10n.posCartMobile(
                                  state.cart.length,
                                  (state.totalCents(tax) / 100).toStringAsFixed(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: state.cart.isEmpty
                                ? null
                                : () => _showCheckout(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size(56, 48),
                            ),
                            child: const Icon(Icons.payments),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
          if (!isWide)
            Positioned(
              right: 20,
              bottom: 88,
              child: FloatingActionButton.extended(
                onPressed: _openCameraScan,
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.commonScan),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showQuickAdd(BuildContext context) async {
    final l10n = context.l10n;
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => const _QuickAddDialog(),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.posProductAdded)),
      );
    }
  }
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _CheckoutIntent extends Intent {
  const _CheckoutIntent();
}

class _DirectSaleIntent extends Intent {
  const _DirectSaleIntent();
}

class _HoldSaleIntent extends Intent {
  const _HoldSaleIntent();
}

class _PosSearchBar extends StatelessWidget {
  const _PosSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCameraScan,
    required this.onQuickAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCameraScan;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: l10n.posScanBarcodeSearch,
              prefixIcon: const Icon(Icons.qr_code_scanner),
              suffixIcon: IconButton(
                onPressed: () => onSubmitted(controller.text),
                icon: const Icon(Icons.keyboard_return),
                tooltip: l10n.posAddToCartTooltip,
              ),
            ),
            textInputAction: TextInputAction.done,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onCameraScan,
          icon: const Icon(Icons.camera_alt_outlined),
          tooltip: l10n.posScanCameraTooltip,
        ),
        IconButton.filled(
          onPressed: onQuickAdd,
          icon: const Icon(Icons.add),
          tooltip: l10n.posQuickAddProduct,
        ),
      ],
    );
  }
}

class _PosCartPanel extends ConsumerWidget {
  const _PosCartPanel({
    this.scrollController,
    required this.onCheckout,
    required this.onHold,
    required this.onCustomer,
  });

  final ScrollController? scrollController;
  final VoidCallback onCheckout;
  final VoidCallback onHold;
  final VoidCallback onCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(posControllerProvider);
    final tax = ref.watch(posTaxProvider);
    final controller = ref.read(posControllerProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Text(
                  l10n.posCart,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: state.cart.isEmpty ? null : onCustomer,
                  child: Text(
                    state.customerName == null ? l10n.colCustomer : state.customerName!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: state.cart.isEmpty ? null : onHold,
                  child: Text(l10n.posHold),
                ),
                TextButton(
                  onPressed:
                      state.cart.isEmpty ? null : controller.clearCart,
                  child: Text(l10n.posClear),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.cart.isEmpty
                ? Center(
                    child: Text(
                      l10n.posScanOrTapProducts,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = state.cart[index];
                      return _CartLine(
                        item: item,
                        onQtyChanged: (q) =>
                            controller.setCartItemQuantity(item.productId, q),
                        onRemove: () =>
                            controller.removeFromCart(item.productId),
                        onEditPrice: () => _editCartPrice(context, ref, item),
                      );
                    },
                  ),
          ),
          _CheckoutBar(
            state: state,
            tax: tax,
            onDiscount: () => _editDiscount(context, ref),
            onCheckout: state.cart.isEmpty ? null : onCheckout,
            onCustomer: onCustomer,
          ),
        ],
      ),
    );
  }
}

Future<void> _editCartPrice(
  BuildContext context,
  WidgetRef ref,
  PosCartItem item,
) async {
  final l10n = context.l10n;
  final price = TextEditingController(
    text: (item.unitPriceCents / 100).toStringAsFixed(2),
  );
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.posEditPrice(item.name)),
      content: TextField(
        controller: price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l10n.posSellingPrice,
          helperText: l10n.posCatalogPrice(
            (item.catalogPriceCents / 100).toStringAsFixed(2),
          ),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonApply)),
      ],
    ),
  );
  if (ok == true) {
    final cents = ((double.tryParse(price.text) ?? 0) * 100).round();
    final applied = await ref
        .read(posControllerProvider.notifier)
        .setCartItemPrice(item.productId, cents);
    if (context.mounted && !applied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.posPriceOverrideDisabled),
        ),
      );
    }
  }
  price.dispose();
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onEditPrice,
  });

  final PosCartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;
  final VoidCallback onEditPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                GestureDetector(
                  onTap: onEditPrice,
                  child: Text(
                    '${(item.unitPriceCents / 100).toStringAsFixed(2)} each'
                    '${item.priceOverridden ? ' (edited)' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: item.priceOverridden
                              ? Colors.orange.shade800
                              : null,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
                Text(
                  'Line: ${(item.lineTotalCents / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          _QtyStepper(
            value: item.quantity,
            onChanged: onQtyChanged,
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: value > 1 ? () => onChanged(value - 1) : () => onChanged(0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

Future<void> _editDiscount(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Order discount'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Discount amount'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apply')),
      ],
    ),
  );
  if (ok == true) {
    final cents = ((double.tryParse(controller.text) ?? 0) * 100).round();
    ref.read(posControllerProvider.notifier).setOrderDiscountCents(cents);
  }
  controller.dispose();
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.state,
    required this.tax,
    required this.onDiscount,
    required this.onCheckout,
    required this.onCustomer,
  });

  final PosState state;
  final PosTaxCalculator tax;
  final VoidCallback onDiscount;
  final VoidCallback? onCheckout;
  final VoidCallback onCustomer;

  String _m(int cents) => (cents / 100).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _line(l10n.commonSubtotal, _m(state.subtotalCents)),
          if (state.orderDiscountCents > 0)
            _line(l10n.posDiscount, '-${_m(state.orderDiscountCents)}'),
          if (state.taxCents > 0)
            _line(
              '${tax.displayLabel}${tax.taxInclusive ? l10n.posTaxInclSuffix : ''}',
              _m(state.taxCents),
            ),
          if (state.customerName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      state.customerName!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: onCustomer,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Change', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${state.cart.length} items',
                style: const TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              Text(
                _m(state.totalCents(tax)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onDiscount,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
            ),
            child: Text(l10n.posAddDiscount),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onCheckout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(l10n.posCheckoutShortcut),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
}

class _QuickAddDialog extends ConsumerStatefulWidget {
  const _QuickAddDialog();

  @override
  ConsumerState<_QuickAddDialog> createState() => _QuickAddDialogState();
}

class _QuickAddDialogState extends ConsumerState<_QuickAddDialog> {
  final _name = TextEditingController();
  final _barcode = TextEditingController();
  final _cost = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '1');

  @override
  void dispose() {
    _name.dispose();
    _barcode.dispose();
    _cost.dispose();
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  int _toCents(String s) {
    final v = double.tryParse(s.trim()) ?? 0;
    return (v * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(posControllerProvider.notifier);
    return AlertDialog(
      title: Text(l10n.posQuickAddProduct),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.productNameRequired),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _barcode,
                decoration: InputDecoration(labelText: '${l10n.barcodeLabel} (${l10n.commonOptional})'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cost,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: l10n.productsCost),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: l10n.sellPriceRequired),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.commonQuantity),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () async {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            await controller.quickAddProduct(
              name: name,
              barcode: _barcode.text.trim(),
              costCents: _toCents(_cost.text),
              priceCents: _toCents(_price.text),
              quantity: int.tryParse(_qty.text.trim()) ?? 1,
            );
            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
