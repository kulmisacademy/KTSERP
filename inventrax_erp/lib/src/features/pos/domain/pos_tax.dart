/// Tax calculation from store settings (basis points = 1/100 of a percent).
class PosTaxCalculator {
  const PosTaxCalculator({
    this.taxRateBps,
    this.taxInclusive = false,
    this.taxName,
  });

  final int? taxRateBps;
  final bool taxInclusive;
  final String? taxName;

  bool get hasTax => taxRateBps != null && taxRateBps! > 0;

  String get displayLabel => taxName?.isNotEmpty == true ? taxName! : 'Tax';

  /// Taxable amount after order-level discount.
  int taxableSubtotalCents(int subtotalCents, int orderDiscountCents) {
    final v = subtotalCents - orderDiscountCents;
    return v < 0 ? 0 : v;
  }

  /// Tax amount for display and receipt (exclusive: added to total; inclusive: extracted).
  int taxCentsFor(int subtotalCents, int orderDiscountCents) {
    if (!hasTax) return 0;
    final base = taxableSubtotalCents(subtotalCents, orderDiscountCents);
    if (base == 0) return 0;
    final bps = taxRateBps!;
    if (taxInclusive) {
      return (base * bps / (10000 + bps)).round();
    }
    return (base * bps / 10000).round();
  }

  /// Grand total respecting inclusive vs exclusive tax.
  int grandTotalCents(int subtotalCents, int orderDiscountCents) {
    final afterDiscount = taxableSubtotalCents(subtotalCents, orderDiscountCents);
    if (!hasTax || taxInclusive) return afterDiscount;
    return afterDiscount + taxCentsFor(subtotalCents, orderDiscountCents);
  }
}
