/// Invoice or line discount — fixed amount or percentage (basis points).
enum DiscountKind { none, fixedCents, percentBps }

class InvoiceDiscount {
  const InvoiceDiscount({this.kind = DiscountKind.none, this.value = 0});

  final DiscountKind kind;

  /// Fixed cents when [kind] is fixedCents; basis points (1000 = 10%) when percentBps.
  final int value;

  static const none = InvoiceDiscount();

  bool get isActive => kind != DiscountKind.none && value > 0;

  int centsFor(int baseCents) {
    if (!isActive || baseCents <= 0) return 0;
    return switch (kind) {
      DiscountKind.fixedCents => value.clamp(0, baseCents),
      DiscountKind.percentBps => (baseCents * value / 10000).round().clamp(0, baseCents),
      DiscountKind.none => 0,
    };
  }

  InvoiceDiscount copyWith({DiscountKind? kind, int? value}) {
    return InvoiceDiscount(kind: kind ?? this.kind, value: value ?? this.value);
  }

  Map<String, dynamic> toJson() => {'kind': kind.name, 'value': value};

  factory InvoiceDiscount.fromJson(Map<String, dynamic>? m) {
    if (m == null) return none;
    final kind = DiscountKind.values.firstWhere(
      (k) => k.name == m['kind'],
      orElse: () => DiscountKind.none,
    );
    return InvoiceDiscount(kind: kind, value: m['value'] as int? ?? 0);
  }
}
