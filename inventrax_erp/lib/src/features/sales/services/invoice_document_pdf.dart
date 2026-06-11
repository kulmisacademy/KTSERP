import 'package:flutter/foundation.dart' show Uint8List;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/media/branded_pdf_header.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../core/l10n/invoice_pdf_labels.dart';
import '../domain/invoice_display_preferences.dart';
import '../domain/invoice_document.dart';

/// PDF renderer using the same [InvoiceDocument] model as on-screen preview.
Future<Uint8List> buildInvoiceDocumentPdf({
  required InvoiceDocument doc,
  StoreSetting? settings,
  String localeCode = 'en',
  bool compact = true,
}) async {
  final branding = await StoreBrandingPdf.fromSettings(settings);
  final labels = InvoicePdfLabels.fromLocaleCode(localeCode);
  final money = (int c) => formatMoney(c, currency: doc.currencyCode);
  final dateFmt = DateFormat.yMMMd(localeCode);
  final padH = compact ? 20.0 : 44.0;
  final padV = compact ? 18.0 : 40.0;

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.fromLTRB(padH, padV, padH, padV),
      build: (ctx) => [
        _pdfHeader(branding, doc, dateFmt),
        pw.SizedBox(height: compact ? 14 : 24),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _pdfCustomer(doc)),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _badge('${labels.statusPrefix}: ${doc.status}'),
                pw.SizedBox(height: 4),
                _badge('${labels.paymentPrefix}: ${doc.paymentStatus}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: compact ? 14 : 20),
        _pdfItemsTable(doc, money, labels),
        pw.SizedBox(height: compact ? 14 : 16),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(width: 260, child: _pdfTotals(doc, money, labels)),
        ),
        if (branding.buildFooter() != null) ...[
          pw.SizedBox(height: 16),
          branding.buildFooter()!,
        ],
      ],
    ),
  );
  return pdf.save();
}

pw.Widget _pdfHeader(
  StoreBrandingPdf branding,
  InvoiceDocument doc,
  DateFormat dateFmt,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      branding.buildHeader(
        doc.invoiceTitle.toUpperCase(),
        subtitle: '#${doc.invoiceNumber} • ${dateFmt.format(doc.createdAt)}',
        asOf: doc.createdAt,
      ),
    ],
  );
}

pw.Widget _pdfCustomer(InvoiceDocument doc) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(10),
      color: const PdfColor.fromInt(0xFFF8FAFC),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          doc.billToLabel.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.teal700,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          doc.displayCustomerName,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        if (doc.customerPhone?.isNotEmpty == true)
          pw.Text(doc.customerPhone!, style: const pw.TextStyle(fontSize: 9)),
        if (doc.customerEmail?.isNotEmpty == true)
          pw.Text(doc.customerEmail!, style: const pw.TextStyle(fontSize: 9)),
        if (doc.customerAddress?.isNotEmpty == true)
          pw.Text(doc.customerAddress!, style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}

pw.Widget _badge(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey200,
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
  );
}

pw.Widget _pdfItemsTable(
  InvoiceDocument doc,
  String Function(int) money,
  InvoicePdfLabels labels,
) {
  final cols = InvoiceTableLayout.visibleColumns(doc.display);
  final headers = InvoiceTableLayout.headerLabels(
    doc.display,
    product: labels.product,
    sku: labels.sku,
    qty: labels.qty,
    unitPrice: labels.unitPrice,
    discount: labels.discount,
    tax: labels.tax,
    lineTotal: labels.lineTotal,
  );

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    columnWidths: InvoiceTableLayout.pdfColumnWidths(doc.display),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9)),
        children: headers
            .map(
              (h) => pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Text(
                  h,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
            )
            .toList(),
      ),
      ...doc.lines.map((line) {
        final cells = cols.map((col) {
          return switch (col) {
            InvoiceTableColumn.product => line.name,
            InvoiceTableColumn.sku => line.barcode ?? '—',
            InvoiceTableColumn.qty => line.quantity == line.quantity.roundToDouble()
                ? '${line.quantity.toInt()}'
                : line.quantity.toStringAsFixed(2),
            InvoiceTableColumn.unitPrice => money(line.unitPriceCents),
            InvoiceTableColumn.discount =>
              line.lineDiscountCents > 0 ? money(line.lineDiscountCents) : '—',
            InvoiceTableColumn.tax =>
              line.lineTaxCents > 0 ? money(line.lineTaxCents) : '—',
            InvoiceTableColumn.lineTotal => money(line.lineTotalCents),
          };
        });
        return pw.TableRow(
          children: cells
              .map(
                (c) => pw.Padding(
                  padding: const pw.EdgeInsets.all(7),
                  child: pw.Text(c, style: const pw.TextStyle(fontSize: 8)),
                ),
              )
              .toList(),
        );
      }),
    ],
  );
}

pw.Widget _pdfTotals(
  InvoiceDocument doc,
  String Function(int) money,
  InvoicePdfLabels labels,
) {
  final t = doc.totals;
  pw.Widget row(String label, String value, {bool grand = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: grand ? 12 : 9,
              fontWeight: grand ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: grand ? 14 : 9,
              fontWeight: pw.FontWeight.bold,
              color: grand ? PdfColors.teal700 : null,
            ),
          ),
        ],
      ),
    );
  }

  final display = doc.display;
  return pw.Column(
    children: [
      row(labels.subtotal, money(t.netAfterLineDiscountsCents)),
      if (t.showLineDiscounts)
        row('Item discounts', '-${money(t.lineDiscountsCents)}'),
      if (t.showInvoiceDiscount)
        row('Invoice discount', '-${money(t.invoiceDiscountCents)}'),
      if (display.showTax && t.showTax) row(doc.taxLabel, money(t.taxCents)),
      if (t.paidCents > 0) row(labels.paid, money(t.paidCents)),
      if (t.remainingCents > 0) row(labels.remaining, money(t.remainingCents)),
      pw.Divider(color: PdfColors.grey300),
      row(labels.grandTotal, money(t.grandTotalCents), grand: true),
    ],
  );
}
