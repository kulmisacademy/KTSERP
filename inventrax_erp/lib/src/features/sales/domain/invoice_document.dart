import '../../custom_sales/domain/custom_sales_models.dart';
import '../../pos/domain/pos_tax.dart';
import 'invoice_branding.dart';
import 'invoice_display_preferences.dart';
import 'invoice_totals_engine.dart';
import 'sale_invoice_data.dart';

/// Shared invoice template — preview UI and PDF render from the same model.
class InvoiceDocument {
  const InvoiceDocument({
    required this.invoiceNumber,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.dueDate,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    required this.lines,
    required this.totals,
    required this.branding,
    required this.currencyCode,
    this.taxName,
    this.paymentMethod,
    this.notes,
    this.invoiceTitle = 'Invoice',
    this.billToLabel = 'Bill to',
    this.walkInLabel = 'Walk-in customer',
    this.display = InvoiceDisplayPreferences.compact,
  });

  final String invoiceNumber;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final List<InvoiceDocumentLine> lines;
  final InvoiceTotalsBreakdown totals;
  final InvoiceBranding branding;
  final String currencyCode;
  final String? taxName;
  final String? paymentMethod;
  final String? notes;
  final String invoiceTitle;
  final String billToLabel;
  final String walkInLabel;
  final InvoiceDisplayPreferences display;

  String get displayCustomerName =>
      customerName.trim().isEmpty ? walkInLabel : customerName;

  String get taxLabel =>
      taxName?.trim().isNotEmpty == true ? taxName! : 'Tax';

  factory InvoiceDocument.fromSale({
    required SaleInvoiceData data,
    required InvoiceBranding branding,
    String invoiceTitle = 'Invoice',
    String billToLabel = 'Bill to',
    String walkInLabel = 'Walk-in customer',
    InvoiceDisplayPreferences display = InvoiceDisplayPreferences.compact,
  }) {
    return InvoiceDocument(
      invoiceNumber: data.invoiceNumber,
      status: data.status,
      paymentStatus: data.paymentStatus,
      createdAt: data.createdAt,
      dueDate: data.dueDate,
      customerName: data.customerName ?? '',
      customerPhone: data.customerPhone,
      customerEmail: data.customerEmail,
      customerAddress: data.customerAddress,
      lines: data.lines
          .map(
            (l) => InvoiceDocumentLine(
              name: l.name,
              barcode: l.barcode,
              quantity: l.quantity,
              unitPriceCents: l.unitPriceCents,
              lineDiscountCents: l.lineDiscountCents,
              lineTaxCents: l.lineTaxCents,
              lineTotalCents: l.lineTotalCents,
            ),
          )
          .toList(),
      totals: InvoiceTotalsEngine.fromSaleInvoice(data),
      branding: branding,
      currencyCode: data.currencyCode,
      taxName: data.taxName,
      paymentMethod: data.paymentMethod,
      notes: data.notes,
      invoiceTitle: invoiceTitle,
      billToLabel: billToLabel,
      walkInLabel: walkInLabel,
      display: display,
    );
  }

  factory InvoiceDocument.fromCustomSales({
    required CustomSalesState state,
    required InvoiceBranding branding,
    required PosTaxCalculator taxCalculator,
    String currencyCode = 'USD',
    String? taxName,
    String invoiceTitle = 'Invoice',
    String billToLabel = 'Bill to',
    String walkInLabel = 'Walk-in customer',
    InvoiceDisplayPreferences display = InvoiceDisplayPreferences.compact,
  }) {
    final totals = InvoiceTotalsEngine.compute(
      lines: state.lines,
      invoiceDiscount: state.invoiceDiscount,
      taxCalculator: taxCalculator,
      taxEnabled: state.taxEnabled,
    );
    final ref = state.invoiceReference?.trim();
    return InvoiceDocument(
      invoiceNumber: ref?.isNotEmpty == true ? ref!.toUpperCase() : 'DRAFT',
      status: 'draft',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
      customerName: state.customerName ?? '',
      customerPhone: state.customerPhone,
      customerEmail: state.customerEmail,
      customerAddress: state.customerAddress,
      lines: state.lines
          .map(
            (l) => InvoiceDocumentLine(
              name: l.name,
              barcode: l.barcode,
              quantity: l.quantity.toDouble(),
              unitPriceCents: l.unitPriceCents,
              lineDiscountCents: l.lineDiscountCents,
              lineTotalCents: l.lineTotalCents,
            ),
          )
          .toList(),
      totals: totals,
      branding: branding,
      currencyCode: currencyCode,
      taxName: taxName,
      notes: state.notes,
      invoiceTitle: invoiceTitle,
      billToLabel: billToLabel,
      walkInLabel: walkInLabel,
      display: display,
    );
  }
}

class InvoiceDocumentLine {
  const InvoiceDocumentLine({
    required this.name,
    this.barcode,
    required this.quantity,
    required this.unitPriceCents,
    this.lineDiscountCents = 0,
    this.lineTaxCents = 0,
    required this.lineTotalCents,
  });

  final String name;
  final String? barcode;
  final double quantity;
  final int unitPriceCents;
  final int lineDiscountCents;
  final int lineTaxCents;
  final int lineTotalCents;
}
