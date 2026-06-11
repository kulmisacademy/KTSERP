class PosCartItem {
  const PosCartItem({
    required this.productId,
    required this.name,
    required this.barcode,
    required this.unitPriceCents,
    required this.unitCostCents,
    required this.quantity,
    required this.catalogPriceCents,
    this.isDirectSale = false,
  });

  final String productId;
  final String name;
  final String? barcode;
  final int unitPriceCents;
  final int unitCostCents;
  final int quantity;
  final int catalogPriceCents;
  final bool isDirectSale;

  bool get priceOverridden => unitPriceCents != catalogPriceCents;

  int get lineTotalCents => unitPriceCents * quantity;

  PosCartItem copyWith({int? quantity, int? unitPriceCents}) {
    return PosCartItem(
      productId: productId,
      name: name,
      barcode: barcode,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      unitCostCents: unitCostCents,
      quantity: quantity ?? this.quantity,
      catalogPriceCents: catalogPriceCents,
      isDirectSale: isDirectSale,
    );
  }
}
