class PurchaseCartLine {
  const PurchaseCartLine({
    required this.productId,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.costCents,
    required this.stockQty,
    required this.catalogSellCents,
    this.newSellCents,
  });

  final String productId;
  final String name;
  final String? barcode;
  final int quantity;
  final int costCents;
  final int stockQty;
  final int catalogSellCents;
  final int? newSellCents;

  int get lineTotalCents => quantity * costCents;

  int get sellCents => newSellCents ?? catalogSellCents;

  int get unitMarginCents => sellCents - costCents;

  double? get marginPercent {
    if (sellCents <= 0) return null;
    return unitMarginCents / sellCents;
  }

  PurchaseCartLine copyWith({
    int? quantity,
    int? costCents,
    int? newSellCents,
  }) {
    return PurchaseCartLine(
      productId: productId,
      name: name,
      barcode: barcode,
      quantity: quantity ?? this.quantity,
      costCents: costCents ?? this.costCents,
      stockQty: stockQty,
      catalogSellCents: catalogSellCents,
      newSellCents: newSellCents ?? this.newSellCents,
    );
  }
}
