import '../../../core/store/store_branding.dart';
import '../../../data/local/app_database.dart';
import 'invoice_document.dart';

/// Snapshot for premium A4 invoice view / PDF (store branding + sale at render time).
class SaleInvoiceData {
  const SaleInvoiceData({
    required this.saleId,
    required this.invoiceNumber,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.dueDate,
    required this.storeName,
    this.storePhone,
    this.storeEmail,
    this.storeAddress,
    this.taxNumber,
    this.invoiceFooter,
    this.logoLocalPath,
    this.logoRemoteUrl,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.taxCents,
    required this.totalCents,
    required this.paidCents,
    required this.currencyCode,
    this.taxName,
    this.paymentMethod,
    this.notes,
  });

  final String saleId;
  final String invoiceNumber;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? dueDate;

  final String storeName;
  final String? storePhone;
  final String? storeEmail;
  final String? storeAddress;
  final String? taxNumber;
  final String? invoiceFooter;
  final String? logoLocalPath;
  final String? logoRemoteUrl;

  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerAddress;

  final List<SaleInvoiceLine> lines;

  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;
  final int paidCents;
  final String currencyCode;
  final String? taxName;
  final String? paymentMethod;
  final String? notes;

  int get remainingCents => (totalCents - paidCents).clamp(0, totalCents);

  String get storeInitials {
    final parts = storeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  factory SaleInvoiceData.fromSale({
    required Sale sale,
    required List<SaleItem> items,
    required StoreSetting? settings,
    Customer? customer,
    String? paymentMethod,
    String? logoRemoteUrl,
  }) {
    return SaleInvoiceData(
      saleId: sale.id,
      invoiceNumber: sale.id.substring(0, 8).toUpperCase(),
      status: sale.status,
      paymentStatus: sale.paymentStatus,
      createdAt: sale.createdAt,
      storeName: StoreBranding.displayName(settings),
      storePhone: settings?.phone,
      storeEmail: settings?.email,
      storeAddress: settings?.address,
      taxNumber: settings?.taxNumber,
      invoiceFooter: settings?.invoiceFooter,
      logoLocalPath: settings?.logoLocalPath,
      logoRemoteUrl: logoRemoteUrl,
      customerName: customer?.name,
      customerPhone: customer?.phone,
      customerEmail: customer?.email,
      customerAddress: customer?.address,
      lines: items
          .map(
            (i) => SaleInvoiceLine(
              name: i.name,
              barcode: i.barcode,
              quantity: i.quantity.toDouble(),
              unitPriceCents: i.unitPriceCents,
              lineTotalCents: i.lineTotalCents,
            ),
          )
          .toList(),
      subtotalCents: sale.subtotalCents,
      discountCents: sale.discountCents,
      taxCents: sale.taxCents,
      totalCents: sale.totalCents,
      paidCents: sale.paidCents,
      currencyCode: settings?.currencyCode ?? 'USD',
      taxName: settings?.taxName,
      paymentMethod: paymentMethod,
      notes: sale.notes,
    );
  }

  /// Bridge [InvoiceDocument] → on-screen invoice view (shared with PDF model).
  factory SaleInvoiceData.fromDocument(InvoiceDocument doc) {
    final b = doc.branding;
    return SaleInvoiceData(
      saleId: 'draft',
      invoiceNumber: doc.invoiceNumber,
      status: doc.status,
      paymentStatus: doc.paymentStatus,
      createdAt: doc.createdAt,
      dueDate: doc.dueDate,
      storeName: b.storeName,
      storePhone: b.phone,
      storeEmail: b.email,
      storeAddress: b.address,
      taxNumber: b.taxNumber,
      invoiceFooter: b.invoiceFooter,
      logoLocalPath: b.logoLocalPath,
      logoRemoteUrl: b.logoRemoteUrl,
      customerName: doc.customerName,
      customerPhone: doc.customerPhone,
      customerEmail: doc.customerEmail,
      customerAddress: doc.customerAddress,
      lines: doc.lines
          .map(
            (l) => SaleInvoiceLine(
              name: l.name,
              barcode: l.barcode,
              quantity: l.quantity,
              unitPriceCents: l.unitPriceCents,
              lineTotalCents: l.lineTotalCents,
              lineDiscountCents: l.lineDiscountCents,
              lineTaxCents: l.lineTaxCents,
            ),
          )
          .toList(),
      subtotalCents: doc.totals.netAfterLineDiscountsCents,
      discountCents: doc.totals.totalDiscountCents,
      taxCents: doc.totals.taxCents,
      totalCents: doc.totals.grandTotalCents,
      paidCents: doc.totals.paidCents,
      currencyCode: doc.currencyCode,
      taxName: doc.taxName,
      paymentMethod: doc.paymentMethod,
      notes: doc.notes,
    );
  }
}

class SaleInvoiceLine {
  const SaleInvoiceLine({
    required this.name,
    this.barcode,
    required this.quantity,
    required this.unitPriceCents,
    required this.lineTotalCents,
    this.lineDiscountCents = 0,
    this.lineTaxCents = 0,
  });

  final String name;
  final String? barcode;
  final double quantity;
  final int unitPriceCents;
  final int lineTotalCents;
  final int lineDiscountCents;
  final int lineTaxCents;
}
