import 'dart:convert';

import 'pos_models.dart';
import 'pos_state.dart';

/// Serializes POS cart state for held sales (offline JSON in SQLite).
class PosStateSerializer {
  static String encode(PosState state) => jsonEncode(toMap(state));

  static PosState decode(String json) =>
      fromMap(jsonDecode(json) as Map<String, dynamic>);

  static Map<String, dynamic> toMap(PosState s) => {
        'cart': s.cart.map(_itemToMap).toList(),
        'orderDiscountCents': s.orderDiscountCents,
        'taxCents': s.taxCents,
        'customerId': s.customerId,
        'customerName': s.customerName,
        'notes': s.notes,
      };

  static PosState fromMap(Map<String, dynamic> m) => PosState(
        cart: (m['cart'] as List<dynamic>)
            .map((e) => _itemFromMap(e as Map<String, dynamic>))
            .toList(),
        orderDiscountCents: m['orderDiscountCents'] as int? ?? 0,
        taxCents: m['taxCents'] as int? ?? 0,
        customerId: m['customerId'] as String?,
        customerName: m['customerName'] as String?,
        notes: m['notes'] as String?,
      );

  static Map<String, dynamic> _itemToMap(PosCartItem i) => {
        'productId': i.productId,
        'name': i.name,
        'barcode': i.barcode,
        'unitPriceCents': i.unitPriceCents,
        'unitCostCents': i.unitCostCents,
        'catalogPriceCents': i.catalogPriceCents,
        'quantity': i.quantity,
        'isDirectSale': i.isDirectSale,
      };

  static PosCartItem _itemFromMap(Map<String, dynamic> m) => PosCartItem(
        productId: m['productId'] as String,
        name: m['name'] as String,
        barcode: m['barcode'] as String?,
        unitPriceCents: m['unitPriceCents'] as int,
        unitCostCents: m['unitCostCents'] as int? ?? 0,
        catalogPriceCents: m['catalogPriceCents'] as int? ??
            m['unitPriceCents'] as int,
        quantity: m['quantity'] as int,
        isDirectSale: m['isDirectSale'] as bool? ?? false,
      );
}
