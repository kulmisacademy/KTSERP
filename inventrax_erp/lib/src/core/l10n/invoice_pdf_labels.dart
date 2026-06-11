/// Localized invoice PDF strings (no BuildContext in PDF builder).
class InvoicePdfLabels {
  const InvoicePdfLabels({
    required this.product,
    required this.sku,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.lineTotal,
    required this.statusPrefix,
    required this.paymentPrefix,
    required this.subtotal,
    required this.paid,
    required this.remaining,
    required this.grandTotal,
  });

  final String product;
  final String sku;
  final String qty;
  final String unitPrice;
  final String discount;
  final String tax;
  final String lineTotal;
  final String statusPrefix;
  final String paymentPrefix;
  final String subtotal;
  final String paid;
  final String remaining;
  final String grandTotal;

  factory InvoicePdfLabels.fromLocaleCode(String code) {
    switch (code.split('_').first) {
      case 'so':
        return const InvoicePdfLabels(
          product: 'Alaab',
          sku: 'Barcode',
          qty: 'Tirada',
          unitPrice: 'Qiimaha',
          discount: 'Qiimo dhimis',
          tax: 'Canshuur',
          lineTotal: 'Wadarta',
          statusPrefix: 'Xaalad',
          paymentPrefix: 'Lacag bixinta',
          subtotal: 'Wadarta hoose',
          paid: 'La bixiyay',
          remaining: 'Hadhaaga',
          grandTotal: 'Wadarta guud',
        );
      case 'ar':
        return const InvoicePdfLabels(
          product: 'المنتج',
          sku: 'الباركود',
          qty: 'الكمية',
          unitPrice: 'سعر الوحدة',
          discount: 'الخصم',
          tax: 'الضريبة',
          lineTotal: 'الإجمالي',
          statusPrefix: 'الحالة',
          paymentPrefix: 'الدفع',
          subtotal: 'المجموع الفرعي',
          paid: 'المدفوع',
          remaining: 'المتبقي',
          grandTotal: 'الإجمالي الكلي',
        );
      default:
        return const InvoicePdfLabels(
          product: 'Product',
          sku: 'SKU',
          qty: 'Qty',
          unitPrice: 'Unit',
          discount: 'Disc.',
          tax: 'Tax',
          lineTotal: 'Total',
          statusPrefix: 'Status',
          paymentPrefix: 'Payment',
          subtotal: 'Subtotal',
          paid: 'Paid',
          remaining: 'Balance due',
          grandTotal: 'Grand total',
        );
    }
  }
}
