import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/store/active_store_scope.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../accounting/data/accounting_provider.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../domain/pos_models.dart';
import '../domain/pos_state.dart';
import '../domain/pos_state_serializer.dart';
import '../../../core/ux/feedback_service.dart';
import '../../dashboard/dashboard_providers.dart';
import 'pos_products_provider.dart';

const _uuid = Uuid();

final heldSalesProvider = StreamProvider.autoDispose<List<HeldSale>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final scope = ref.watch(activeStoreScopeProvider);
  return db
      .watchHeldSales(tenantId: scope.tenantId, storeId: scope.storeId)
      .map(
        (rows) => rows
            .where(
              (h) =>
                  h.id != PosController.autosaveHeldId &&
                  !h.id.startsWith('custom-sales-'),
            )
            .toList(),
      );
});

class PosController extends Notifier<PosState> {
  AppDatabase get _db => ref.read(appDatabaseProvider);
  Timer? _autosaveTimer;

  static const autosaveHeldId = 'pos-autosave';
  static const _autosaveHeldId = autosaveHeldId;

  Future<void> _tryRestoreAutosave() async {
    if (state.cart.isNotEmpty) return;
    final held = await _db.getHeldSale(_autosaveHeldId);
    if (held == null) return;
    try {
      state = PosStateSerializer.decode(held.payloadJson);
    } catch (_) {
      // Corrupt draft; discard.
      await _db.deleteHeldSale(_autosaveHeldId);
    }
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), () async {
      if (state.cart.isEmpty) {
        await _db.deleteHeldSale(_autosaveHeldId);
        return;
      }
      await _db.saveHeldSale(
        HeldSalesCompanion.insert(
          id: _autosaveHeldId,
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          label: const Value('Auto-saved cart'),
          payloadJson: PosStateSerializer.encode(state),
        ),
      );
    });
  }

  Future<void> _clearAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
    return _db.deleteHeldSale(_autosaveHeldId);
  }

  void _syncTax() {
    final tax = ref.read(posTaxProvider);
    final cents = tax.taxCentsFor(state.subtotalCents, state.orderDiscountCents);
    if (cents != state.taxCents) {
      state = state.copyWith(taxCents: cents);
    }
  }

  @override
  PosState build() {
    ref.watch(appDatabaseProvider);
    ref.watch(activeStoreScopeProvider);
    ref.listen(activeStoreScopeProvider, (prev, next) {
      if (prev?.storeId != next.storeId || prev?.tenantId != next.tenantId) {
        _autosaveTimer?.cancel();
        _autosaveTimer = null;
        state = const PosState(
          cart: [],
          orderDiscountCents: 0,
          taxCents: 0,
          customerId: null,
          customerName: null,
          notes: null,
        );
      }
    });
    ref.listen(posTaxProvider, (previous, next) => _syncTax());
    Future.microtask(_tryRestoreAutosave);
    ref.onDispose(() {
      _autosaveTimer?.cancel();
      _autosaveTimer = null;
    });
    return const PosState(
      cart: [],
      orderDiscountCents: 0,
      taxCents: 0,
      customerId: null,
      customerName: null,
      notes: null,
    );
  }

  void addProductToCart(Product product) {
    final idx = state.cart.indexWhere((i) => i.productId == product.id);
    if (idx == -1) {
      state = state.copyWith(
        cart: [
          ...state.cart,
          PosCartItem(
            productId: product.id,
            name: product.name,
            barcode: product.barcode,
            unitPriceCents: product.sellingPriceCents,
            unitCostCents: product.purchasePriceCents,
            catalogPriceCents: product.sellingPriceCents,
            quantity: 1,
          ),
        ],
      );
    } else {
      final updated = [...state.cart];
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = state.copyWith(cart: updated);
    }
    _syncTax();
    _scheduleAutosave();
  }

  void addDirectSaleItem({
    required String name,
    required int priceCents,
    required int quantity,
  }) {
    final id = 'direct-${_uuid.v4()}';
    state = state.copyWith(
      cart: [
        ...state.cart,
        PosCartItem(
          productId: id,
          name: name,
          barcode: null,
          unitPriceCents: priceCents,
          unitCostCents: 0,
          catalogPriceCents: priceCents,
          quantity: quantity,
          isDirectSale: true,
        ),
      ],
    );
    _syncTax();
    _scheduleAutosave();
  }

  Future<Product?> lookupBarcode(String raw) async {
    final barcode = raw.trim();
    if (barcode.isEmpty) return null;
    return _db.findProductByBarcodeFast(
      storeId: StoreContext.storeId,
      barcode: barcode,
    );
  }

  Future<bool> onBarcodeSubmitted(String raw) async {
    final product = await lookupBarcode(raw);
    if (product == null) return false;
    unawaited(
      _db.recordScanHit(productId: product.id, storeId: StoreContext.storeId),
    );
    addProductToCart(product);
    return true;
  }

  void addProductFromLookup(Product product) {
    addProductToCart(product);
  }

  void setCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final updated = state.cart
        .map(
          (i) => i.productId == productId ? i.copyWith(quantity: quantity) : i,
        )
        .toList(growable: false);
    state = state.copyWith(cart: updated);
    _syncTax();
    _scheduleAutosave();
  }

  Future<bool> setCartItemPrice(String productId, int unitPriceCents) async {
    final allowOverride =
        ref.read(storeSettingsProvider).value?.allowCashierPriceOverride ?? true;
    if (!allowOverride) return false;

    final item = state.cart.firstWhere((i) => i.productId == productId);
    if (item.unitPriceCents == unitPriceCents) return true;

    await _db.recordAuditLog(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      entity: 'sale_item',
      entityId: productId,
      action: 'price_override',
      field: 'unit_price_cents',
      oldValue: item.unitPriceCents.toString(),
      newValue: unitPriceCents.toString(),
    );

    final updated = state.cart
        .map(
          (i) =>
              i.productId == productId ? i.copyWith(unitPriceCents: unitPriceCents) : i,
        )
        .toList(growable: false);
    state = state.copyWith(cart: updated);
    _syncTax();
    _scheduleAutosave();
    return true;
  }

  void restoreState(PosState saved) {
    state = saved;
    _scheduleAutosave();
  }

  Future<void> holdCurrentSale({String? label}) async {
    if (state.cart.isEmpty) return;
    final id = _uuid.v4();
    await _db.saveHeldSale(
      HeldSalesCompanion.insert(
        id: id,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        label: Value(label),
        payloadJson: PosStateSerializer.encode(state),
      ),
    );
    await _clearAutosave();
    clearCart();
  }

  Future<bool> restoreHeldSale(String heldId) async {
    final held = await _db.getHeldSale(heldId);
    if (held == null) return false;
    if (state.cart.isNotEmpty) return false;
    state = PosStateSerializer.decode(held.payloadJson);
    await _db.deleteHeldSale(heldId);
    _scheduleAutosave();
    return true;
  }

  Future<void> discardHeldSale(String heldId) {
    return _db.deleteHeldSale(heldId);
  }

  void setOrderDiscountCents(int cents) {
    state = state.copyWith(orderDiscountCents: cents < 0 ? 0 : cents);
    _syncTax();
    _scheduleAutosave();
  }

  void setTaxCents(int cents) {
    state = state.copyWith(taxCents: cents < 0 ? 0 : cents);
    _scheduleAutosave();
  }

  void applyAutoTax() => _syncTax();

  void setCustomer({String? id, String? name}) {
    if (id == null && name == null) {
      state = state.copyWith(clearCustomer: true);
    } else {
      state = state.copyWith(customerId: id, customerName: name);
    }
    _scheduleAutosave();
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
    _scheduleAutosave();
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      cart: state.cart.where((i) => i.productId != productId).toList(),
    );
    _syncTax();
    _scheduleAutosave();
  }

  void clearCart() {
    state = const PosState(
      cart: [],
      orderDiscountCents: 0,
      taxCents: 0,
      customerId: null,
      customerName: null,
      notes: null,
    );
    _clearAutosave();
  }

  Future<void> quickAddProduct({
    required String name,
    required String barcode,
    required int costCents,
    required int priceCents,
    required int quantity,
    int? minStockAlert,
  }) async {
    final id = _uuid.v4();
    await _db.upsertProduct(
      ProductsCompanion.insert(
        id: id,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        name: name,
        barcode: Value(barcode.isEmpty ? null : barcode),
        purchasePriceCents: costCents,
        sellingPriceCents: priceCents,
        quantity: Value(quantity),
        minStockAlert: Value(minStockAlert),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<({String saleId, PosState snapshot, String paymentSummary})?> checkout({
    required String method,
    int? paidCents,
    Map<String, int>? splitPayments,
    String? paymentAccountId,
    String? paymentAccountName,
    bool isCredit = false,
    String? customerId,
    String? customerName,
    DateTime? dueDate,
  }) async {
    if (state.cart.isEmpty) return null;

    await _db.ensureSchemaReady();

    final effectiveCustomerId = customerId ?? state.customerId;
    final effectiveCustomerName = customerName ?? state.customerName;
    if (effectiveCustomerId != null || effectiveCustomerName != null) {
      setCustomer(id: effectiveCustomerId, name: effectiveCustomerName);
    }

    final snapshot = state;
    final saleId = _uuid.v4();
    final tax = ref.read(posTaxProvider);
    final subtotal = state.subtotalCents;
    final total = state.totalCents(tax);

    final actualPaid = isCredit
        ? 0
        : (splitPayments != null
            ? splitPayments.values.fold<int>(0, (a, b) => a + b)
            : (paidCents ?? total));
    final paymentStatus = isCredit
        ? 'unpaid'
        : (actualPaid >= total
            ? 'paid'
            : (actualPaid > 0 ? 'partially_paid' : 'unpaid'));

    final sale = SalesCompanion.insert(
      id: saleId,
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      cashierUserId: Value(StoreContext.userId),
      customerId: Value(effectiveCustomerId),
      notes: Value(state.notes),
      subtotalCents: subtotal,
      discountCents: Value(state.orderDiscountCents),
      taxCents: Value(state.taxCents),
      totalCents: total,
      paidCents: Value(actualPaid),
      paymentStatus: Value(paymentStatus),
      paymentJson: jsonEncode(
        splitPayments != null
            ? {
                'method': 'split',
                'lines': splitPayments,
                'totalCents': total,
                'paidCents': actualPaid,
              }
            : {
                'method': isCredit ? 'credit' : method,
                'paidCents': actualPaid,
                if (paymentAccountId != null)
                  'paymentAccountId': paymentAccountId,
                if (paymentAccountName != null)
                  'paymentAccountName': paymentAccountName,
              },
      ),
    );

    final items = state.cart
        .map(
          (i) => SaleItemsCompanion.insert(
            id: _uuid.v4(),
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            saleId: saleId,
            productId: i.isDirectSale ? const Value.absent() : Value(i.productId),
            name: i.name,
            barcode: Value(i.barcode),
            quantity: i.quantity,
            unitPriceCents: i.unitPriceCents,
            unitCostCents: Value(i.unitCostCents),
            lineTotalCents: i.lineTotalCents,
          ),
        )
        .toList(growable: false);

    try {
      await _db.createSaleWithItems(sale: sale, items: items);
    } on InsufficientStockException catch (e) {
      ref.read(feedbackServiceProvider).warning();
      throw StateError(
        'Not enough stock (need ${e.requested}, have ${e.available ?? 0})',
      );
    }
    ref.read(feedbackServiceProvider).checkoutSuccess();
    ref.invalidate(posProductsProvider);
    invalidateDashboardMetricsFrom(ref);

    final savedSale = await _db.getSaleById(
      storeId: StoreContext.storeId,
      saleId: saleId,
    );
    final savedItems = await _db.listSaleItems(
      storeId: StoreContext.storeId,
      saleId: saleId,
    );
    if (savedSale != null) {
      final remaining = total - actualPaid;
      if (remaining > 0 &&
          effectiveCustomerId != null &&
          effectiveCustomerId.isNotEmpty) {
        await _db.createCustomerDebtForSale(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          customerId: effectiveCustomerId,
          saleId: saleId,
          totalCents: total,
          paidCents: actualPaid,
          invoiceNumber: saleId.substring(0, 8).toUpperCase(),
          dueDate: dueDate,
        );
      }

      try {
        await ref.read(accountingEngineProvider).postSale(
              sale: savedSale,
              items: savedItems,
              paymentAccountId: paymentAccountId,
            );
      } catch (_) {
        // Accounting must not block checkout.
      }
    }

    final paymentSummary = splitPayments != null
        ? 'Split (${splitPayments.length} accounts)'
        : (paymentAccountName ?? (isCredit ? 'Credit' : method));
    clearCart();
    return (saleId: saleId, snapshot: snapshot, paymentSummary: paymentSummary);
  }

  Future<void> checkoutCash() async {
    await checkout(method: 'cash');
  }
}

final posControllerProvider = NotifierProvider<PosController, PosState>(
  PosController.new,
);
