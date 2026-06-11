import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/store_context.dart';
import '../../../core/ux/feedback_service.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../accounting/data/accounting_provider.dart';
import '../../dashboard/dashboard_providers.dart';
import '../../pos/presentation/pos_products_provider.dart';
import '../../sales/domain/invoice_discount.dart';
import '../../sales/domain/invoice_display_preferences.dart';
import '../../sales/domain/invoice_totals_engine.dart';
import '../domain/custom_sales_models.dart';
import '../domain/custom_sales_serializer.dart';

const _uuid = Uuid();

final customSalesControllerProvider =
    NotifierProvider<CustomSalesController, CustomSalesState>(
  CustomSalesController.new,
);

class CustomSalesController extends Notifier<CustomSalesState> {
  AppDatabase get _db => ref.read(appDatabaseProvider);
  Timer? _autosaveTimer;

  @override
  CustomSalesState build() {
    ref.watch(appDatabaseProvider);
    Future.microtask(_tryRestoreAutosave);
    ref.onDispose(() => _autosaveTimer?.cancel());
    return const CustomSalesState(lines: []);
  }

  InvoiceTotalsBreakdown _totals() {
    final tax = ref.read(posTaxProvider);
    return state.totals(tax);
  }

  Future<void> _tryRestoreAutosave() async {
    if (state.lines.isNotEmpty) return;
    final held = await _db.getHeldSale(customSalesAutosaveId);
    if (held == null) return;
    try {
      state = CustomSalesSerializer.decode(held.payloadJson);
    } catch (_) {
      await _db.deleteHeldSale(customSalesAutosaveId);
    }
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), () async {
      if (state.lines.isEmpty &&
          state.customerId == null &&
          (state.customerName?.isEmpty ?? true)) {
        await _db.deleteHeldSale(customSalesAutosaveId);
        return;
      }
      await _db.saveHeldSale(
        HeldSalesCompanion.insert(
          id: customSalesAutosaveId,
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
          label: const Value('Custom sales draft'),
          payloadJson: CustomSalesSerializer.encode(state),
        ),
      );
    });
  }

  Future<void> _clearAutosave() {
    _autosaveTimer?.cancel();
    return _db.deleteHeldSale(customSalesAutosaveId);
  }

  void _touch() => _scheduleAutosave();

  void addProduct(Product product) {
    final existing = state.lines.indexWhere((l) => l.productId == product.id);
    if (existing == -1) {
      state = state.copyWith(
        lines: [
          ...state.lines,
          CustomSalesLineItem(
            lineId: _uuid.v4(),
            productId: product.id,
            name: product.name,
            barcode: product.barcode,
            unitPriceCents: product.sellingPriceCents,
            unitCostCents: product.purchasePriceCents,
            catalogPriceCents: product.sellingPriceCents,
            quantity: 1,
            stockQty: product.quantity,
          ),
        ],
      );
    } else {
      final updated = [...state.lines];
      final line = updated[existing];
      updated[existing] = line.copyWith(quantity: line.quantity + 1);
      state = state.copyWith(lines: updated);
    }
    _touch();
  }

  void addManualLine({
    required String name,
    required int unitPriceCents,
    int quantity = 1,
  }) {
    state = state.copyWith(
      lines: [
        ...state.lines,
        CustomSalesLineItem(
          lineId: _uuid.v4(),
          productId: 'direct-${_uuid.v4()}',
          name: name,
          unitPriceCents: unitPriceCents,
          unitCostCents: 0,
          catalogPriceCents: unitPriceCents,
          quantity: quantity,
          isDirectSale: true,
        ),
      ],
    );
    _touch();
  }

  void updateLine(
    String lineId, {
    int? quantity,
    int? unitPriceCents,
    InvoiceDiscount? lineDiscount,
    String? name,
  }) {
    state = state.copyWith(
      lines: state.lines
          .map(
            (l) => l.lineId == lineId
                ? l.copyWith(
                    quantity: quantity,
                    unitPriceCents: unitPriceCents,
                    lineDiscount: lineDiscount,
                    name: name,
                  )
                : l,
          )
          .toList(),
    );
    _touch();
  }

  void removeLine(String lineId) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.lineId != lineId).toList(),
    );
    _touch();
  }

  void setInvoiceDiscount(InvoiceDiscount discount) {
    state = state.copyWith(invoiceDiscount: discount);
    _touch();
  }

  void setTaxEnabled(bool enabled) {
    state = state.copyWith(taxEnabled: enabled);
    _touch();
  }

  void setDisplayPreferences(InvoiceDisplayPreferences prefs) {
    state = state.copyWith(displayPrefs: prefs);
    _scheduleAutosave();
  }

  void setCustomer({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    if (id == null && name == null) {
      state = state.copyWith(clearCustomer: true);
    } else {
      state = state.copyWith(
        customerId: id,
        customerName: name,
        customerPhone: phone,
        customerEmail: email,
        customerAddress: address,
      );
    }
    _scheduleAutosave();
  }

  void setWalkInCustomer({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    state = state.copyWith(
      clearCustomer: true,
      customerName: name?.trim().isEmpty == true ? null : name?.trim(),
      customerPhone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      customerEmail: email?.trim().isEmpty == true ? null : email?.trim(),
      customerAddress:
          address?.trim().isEmpty == true ? null : address?.trim(),
    );
    _scheduleAutosave();
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
    _scheduleAutosave();
  }

  void setInvoiceReference(String? ref) {
    state = state.copyWith(invoiceReference: ref);
    _scheduleAutosave();
  }

  Future<String> saveDraft() async {
    final draftId = state.draftId ?? '$customSalesDraftPrefix${_uuid.v4()}';
    final draftState = state.copyWith(draftId: draftId, isDraft: true);
    state = draftState;
    await _db.saveHeldSale(
      HeldSalesCompanion.insert(
        id: draftId,
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        label: Value(
          draftState.invoiceReference?.trim().isNotEmpty == true
              ? draftState.invoiceReference!.trim()
              : 'Invoice draft',
        ),
        payloadJson: CustomSalesSerializer.encode(draftState),
      ),
    );
    await _clearAutosave();
    return draftId;
  }

  Future<bool> loadDraft(String draftId) async {
    final held = await _db.getHeldSale(draftId);
    if (held == null) return false;
    try {
      state = CustomSalesSerializer.decode(held.payloadJson)
          .copyWith(draftId: draftId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteDraft(String draftId) async {
    await _db.deleteHeldSale(draftId);
    if (state.draftId == draftId) {
      clear();
    }
  }

  void clear() {
    state = const CustomSalesState(lines: []);
    _clearAutosave();
  }

  Future<({String saleId, String paymentSummary})?> checkout({
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
    if (state.lines.isEmpty) return null;

    await _db.ensureSchemaReady();

    final effectiveCustomerId = customerId ?? state.customerId;
    final breakdown = _totals();
    final total = breakdown.grandTotalCents;

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

    final saleId = _uuid.v4();
    final sale = SalesCompanion.insert(
      id: saleId,
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      cashierUserId: Value(StoreContext.userId),
      customerId: Value(effectiveCustomerId),
      notes: Value(
        [
          if (state.invoiceReference?.isNotEmpty == true)
            'Ref: ${state.invoiceReference}',
          if (state.notes?.isNotEmpty == true) state.notes,
        ].join('\n').trim().isEmpty
            ? null
            : [
                if (state.invoiceReference?.isNotEmpty == true)
                  'Ref: ${state.invoiceReference}',
                if (state.notes?.isNotEmpty == true) state.notes,
              ].join('\n'),
      ),
      subtotalCents: breakdown.netAfterLineDiscountsCents,
      discountCents: Value(breakdown.totalDiscountCents),
      taxCents: Value(breakdown.taxCents),
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
                'source': 'custom_sales',
              },
      ),
    );

    final items = state.lines
        .map(
          (i) => SaleItemsCompanion.insert(
            id: _uuid.v4(),
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
            saleId: saleId,
            productId:
                i.isDirectSale ? const Value.absent() : Value(i.productId),
            name: i.name,
            barcode: Value(i.barcode),
            quantity: i.quantity,
            unitPriceCents: i.unitPriceCents,
            unitCostCents: Value(i.unitCostCents),
            lineTotalCents: i.lineTotalCents,
          ),
        )
        .toList(growable: false);

    await _db.createSaleWithItems(sale: sale, items: items);

    if (state.draftId != null) {
      await _db.deleteHeldSale(state.draftId!);
    }
    await _clearAutosave();

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
      } catch (_) {}
    }

    clear();

    final summary = isCredit
        ? 'Credit — ${customerName ?? state.customerName ?? 'Customer'}'
        : '${paymentAccountName ?? method} — ${(actualPaid / 100).toStringAsFixed(2)}';

    return (saleId: saleId, paymentSummary: summary);
  }
}
