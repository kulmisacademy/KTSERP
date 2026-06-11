import '../../custom_sales/domain/custom_sales_models.dart';
import '../../pos/domain/pos_tax.dart';
import 'invoice_discount.dart';
import 'sale_invoice_data.dart';

/// Full invoice math breakdown — single source for UI, PDF, and checkout.
class InvoiceTotalsBreakdown {
  const InvoiceTotalsBreakdown({
    required this.itemsSubtotalCents,
    required this.lineDiscountsCents,
    required this.netAfterLineDiscountsCents,
    required this.invoiceDiscountCents,
    required this.taxableCents,
    required this.taxCents,
    required this.grandTotalCents,
    this.paidCents = 0,
    required this.taxEnabled,
    required this.showLineDiscounts,
    required this.showInvoiceDiscount,
    required this.showTax,
  });

  final int itemsSubtotalCents;
  final int lineDiscountsCents;
  final int netAfterLineDiscountsCents;
  final int invoiceDiscountCents;
  final int taxableCents;
  final int taxCents;
  final int grandTotalCents;
  final int paidCents;
  final bool taxEnabled;
  final bool showLineDiscounts;
  final bool showInvoiceDiscount;
  final bool showTax;

  int get remainingCents =>
      (grandTotalCents - paidCents).clamp(0, grandTotalCents);

  int get totalDiscountCents => lineDiscountsCents + invoiceDiscountCents;
}

abstract final class InvoiceTotalsEngine {
  /// Order: item subtotal → line discount → invoice discount → tax → grand total.
  static InvoiceTotalsBreakdown compute({
    required List<CustomSalesLineItem> lines,
    required InvoiceDiscount invoiceDiscount,
    required PosTaxCalculator taxCalculator,
    required bool taxEnabled,
    int paidCents = 0,
  }) {
    var itemsSubtotal = 0;
    var lineDiscounts = 0;

    for (final line in lines) {
      itemsSubtotal += line.lineSubtotalCents;
      lineDiscounts += line.lineDiscountCents;
    }

    final netAfterLines = (itemsSubtotal - lineDiscounts).clamp(0, itemsSubtotal);
    final invoiceDisc = invoiceDiscount.centsFor(netAfterLines);
    final taxable = (netAfterLines - invoiceDisc).clamp(0, netAfterLines);

    final taxCents = taxEnabled && taxCalculator.hasTax
        ? taxCalculator.taxCentsFor(netAfterLines, invoiceDisc)
        : 0;

    final grand = taxEnabled && taxCalculator.hasTax && !taxCalculator.taxInclusive
        ? taxable + taxCents
        : taxable;

    return InvoiceTotalsBreakdown(
      itemsSubtotalCents: itemsSubtotal,
      lineDiscountsCents: lineDiscounts,
      netAfterLineDiscountsCents: netAfterLines,
      invoiceDiscountCents: invoiceDisc,
      taxableCents: taxable,
      taxCents: taxCents,
      grandTotalCents: grand,
      paidCents: paidCents,
      taxEnabled: taxEnabled,
      showLineDiscounts: lineDiscounts > 0,
      showInvoiceDiscount: invoiceDisc > 0,
      showTax: taxEnabled && taxCents > 0,
    );
  }

  static InvoiceTotalsBreakdown fromSaleInvoice(SaleInvoiceData data) {
    return InvoiceTotalsBreakdown(
      itemsSubtotalCents: data.subtotalCents + _lineDiscFromSale(data),
      lineDiscountsCents: _lineDiscFromSale(data),
      netAfterLineDiscountsCents: data.subtotalCents,
      invoiceDiscountCents: data.discountCents - _lineDiscFromSale(data),
      taxableCents: data.subtotalCents - (data.discountCents - _lineDiscFromSale(data)),
      taxCents: data.taxCents,
      grandTotalCents: data.totalCents,
      paidCents: data.paidCents,
      taxEnabled: data.taxCents > 0,
      showLineDiscounts: _lineDiscFromSale(data) > 0,
      showInvoiceDiscount: (data.discountCents - _lineDiscFromSale(data)) > 0,
      showTax: data.taxCents > 0,
    );
  }

  static int _lineDiscFromSale(SaleInvoiceData data) {
    return data.lines.fold(0, (s, l) => s + l.lineDiscountCents);
  }
}
