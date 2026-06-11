import '../../sales/domain/invoice_discount.dart';
import '../../sales/domain/invoice_display_preferences.dart';
import '../../sales/domain/invoice_totals_engine.dart';
import '../../pos/domain/pos_tax.dart';

/// Line item in the custom sales / quick invoice builder.
class CustomSalesLineItem {
  const CustomSalesLineItem({
    required this.lineId,
    required this.productId,
    required this.name,
    this.barcode,
    required this.unitPriceCents,
    required this.unitCostCents,
    required this.catalogPriceCents,
    required this.quantity,
    this.lineDiscount = InvoiceDiscount.none,
    this.stockQty,
    this.isDirectSale = false,
  });

  final String lineId;
  final String productId;
  final String name;
  final String? barcode;
  final int unitPriceCents;
  final int unitCostCents;
  final int catalogPriceCents;
  final int quantity;
  final InvoiceDiscount lineDiscount;
  final int? stockQty;
  final bool isDirectSale;

  int get lineDiscountCents => lineDiscount.centsFor(lineSubtotalCents);

  bool get priceOverridden => unitPriceCents != catalogPriceCents;

  int get lineSubtotalCents => unitPriceCents * quantity;

  int get lineTotalCents =>
      (lineSubtotalCents - lineDiscountCents).clamp(0, lineSubtotalCents);

  bool get isLowStock =>
      stockQty != null && !isDirectSale && stockQty! <= quantity;

  bool get exceedsStock =>
      stockQty != null && !isDirectSale && quantity > stockQty!;

  CustomSalesLineItem copyWith({
    String? name,
    int? unitPriceCents,
    int? quantity,
    InvoiceDiscount? lineDiscount,
  }) {
    return CustomSalesLineItem(
      lineId: lineId,
      productId: productId,
      name: name ?? this.name,
      barcode: barcode,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      unitCostCents: unitCostCents,
      catalogPriceCents: catalogPriceCents,
      quantity: quantity ?? this.quantity,
      lineDiscount: lineDiscount ?? this.lineDiscount,
      stockQty: stockQty,
      isDirectSale: isDirectSale,
    );
  }
}

/// In-memory state for custom sales invoice builder.
class CustomSalesState {
  const CustomSalesState({
    required this.lines,
    this.invoiceDiscount = InvoiceDiscount.none,
    this.taxEnabled = true,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.notes,
    this.invoiceReference,
    this.draftId,
    this.isDraft = true,
    this.displayPrefs,
  });

  final List<CustomSalesLineItem> lines;
  final InvoiceDiscount invoiceDiscount;
  final bool taxEnabled;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? notes;
  final String? invoiceReference;
  final String? draftId;
  final bool isDraft;
  final InvoiceDisplayPreferences? displayPrefs;

  InvoiceTotalsBreakdown totals(PosTaxCalculator tax) {
    return InvoiceTotalsEngine.compute(
      lines: lines,
      invoiceDiscount: invoiceDiscount,
      taxCalculator: tax,
      taxEnabled: taxEnabled,
    );
  }

  bool get hasStockIssues => lines.any((l) => l.exceedsStock);

  CustomSalesState copyWith({
    List<CustomSalesLineItem>? lines,
    InvoiceDiscount? invoiceDiscount,
    bool? taxEnabled,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? notes,
    String? invoiceReference,
    String? draftId,
    bool? isDraft,
    InvoiceDisplayPreferences? displayPrefs,
    bool clearCustomer = false,
    bool clearDraftId = false,
    bool clearDisplayPrefs = false,
  }) {
    return CustomSalesState(
      lines: lines ?? this.lines,
      invoiceDiscount: invoiceDiscount ?? this.invoiceDiscount,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      customerName: clearCustomer ? null : (customerName ?? this.customerName),
      customerPhone:
          clearCustomer ? null : (customerPhone ?? this.customerPhone),
      customerEmail:
          clearCustomer ? null : (customerEmail ?? this.customerEmail),
      customerAddress:
          clearCustomer ? null : (customerAddress ?? this.customerAddress),
      notes: notes ?? this.notes,
      invoiceReference: invoiceReference ?? this.invoiceReference,
      draftId: clearDraftId ? null : (draftId ?? this.draftId),
      isDraft: isDraft ?? this.isDraft,
      displayPrefs: clearDisplayPrefs
          ? null
          : (displayPrefs ?? this.displayPrefs),
    );
  }
}

/// Prefix for saved custom-sales draft rows in held_sales.
const customSalesDraftPrefix = 'custom-sales-draft-';

const customSalesAutosaveId = 'custom-sales-autosave';

bool isCustomSalesDraftId(String id) =>
    id.startsWith(customSalesDraftPrefix) || id == customSalesAutosaveId;
