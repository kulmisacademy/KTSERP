import 'dart:convert';

import '../../sales/domain/invoice_discount.dart';
import '../../sales/domain/invoice_display_preferences.dart';
import 'custom_sales_models.dart';

class CustomSalesSerializer {
  static String encode(CustomSalesState state) =>
      jsonEncode(_toMap(state));

  static CustomSalesState decode(String json) =>
      _fromMap(jsonDecode(json) as Map<String, dynamic>);

  static Map<String, dynamic> _toMap(CustomSalesState s) => {
        'lines': s.lines.map(_lineToMap).toList(),
        'invoiceDiscount': s.invoiceDiscount.toJson(),
        'taxEnabled': s.taxEnabled,
        'customerId': s.customerId,
        'customerName': s.customerName,
        'customerPhone': s.customerPhone,
        'customerEmail': s.customerEmail,
        'customerAddress': s.customerAddress,
        'notes': s.notes,
        'invoiceReference': s.invoiceReference,
        'draftId': s.draftId,
        'isDraft': s.isDraft,
        'displayPrefs': s.displayPrefs?.toJson(),
        'orderDiscountCents': _legacyOrderDiscount(s),
      };

  static int _legacyOrderDiscount(CustomSalesState s) {
    if (s.invoiceDiscount.kind == DiscountKind.fixedCents) {
      return s.invoiceDiscount.value;
    }
    return 0;
  }

  static CustomSalesState _fromMap(Map<String, dynamic> m) {
    InvoiceDiscount invoiceDiscount;
    if (m['invoiceDiscount'] is Map) {
      invoiceDiscount =
          InvoiceDiscount.fromJson(m['invoiceDiscount'] as Map<String, dynamic>);
    } else {
      final legacy = m['orderDiscountCents'] as int? ?? 0;
      invoiceDiscount = legacy > 0
          ? InvoiceDiscount(kind: DiscountKind.fixedCents, value: legacy)
          : InvoiceDiscount.none;
    }

    return CustomSalesState(
      lines: (m['lines'] as List<dynamic>? ?? [])
          .map((e) => _lineFromMap(e as Map<String, dynamic>))
          .toList(),
      invoiceDiscount: invoiceDiscount,
      taxEnabled: m['taxEnabled'] as bool? ?? true,
      customerId: m['customerId'] as String?,
      customerName: m['customerName'] as String?,
      customerPhone: m['customerPhone'] as String?,
      customerEmail: m['customerEmail'] as String?,
      customerAddress: m['customerAddress'] as String?,
      notes: m['notes'] as String?,
      invoiceReference: m['invoiceReference'] as String?,
      draftId: m['draftId'] as String?,
      isDraft: m['isDraft'] as bool? ?? true,
      displayPrefs: m['displayPrefs'] is Map
          ? InvoiceDisplayPreferences.fromJson(
              m['displayPrefs'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static Map<String, dynamic> _lineToMap(CustomSalesLineItem i) => {
        'lineId': i.lineId,
        'productId': i.productId,
        'name': i.name,
        'barcode': i.barcode,
        'unitPriceCents': i.unitPriceCents,
        'unitCostCents': i.unitCostCents,
        'catalogPriceCents': i.catalogPriceCents,
        'quantity': i.quantity,
        'lineDiscount': i.lineDiscount.toJson(),
        'lineDiscountCents': i.lineDiscountCents,
        'stockQty': i.stockQty,
        'isDirectSale': i.isDirectSale,
      };

  static CustomSalesLineItem _lineFromMap(Map<String, dynamic> m) {
    InvoiceDiscount lineDisc;
    if (m['lineDiscount'] is Map) {
      lineDisc = InvoiceDiscount.fromJson(m['lineDiscount'] as Map<String, dynamic>);
    } else {
      final legacy = m['lineDiscountCents'] as int? ?? 0;
      lineDisc = legacy > 0
          ? InvoiceDiscount(kind: DiscountKind.fixedCents, value: legacy)
          : InvoiceDiscount.none;
    }

    return CustomSalesLineItem(
      lineId: m['lineId'] as String,
      productId: m['productId'] as String,
      name: m['name'] as String,
      barcode: m['barcode'] as String?,
      unitPriceCents: m['unitPriceCents'] as int,
      unitCostCents: m['unitCostCents'] as int? ?? 0,
      catalogPriceCents:
          m['catalogPriceCents'] as int? ?? m['unitPriceCents'] as int,
      quantity: m['quantity'] as int,
      lineDiscount: lineDisc,
      stockQty: m['stockQty'] as int?,
      isDirectSale: m['isDirectSale'] as bool? ?? false,
    );
  }
}
