import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show Uint8List;

import '../../../core/design/app_colors.dart';
import '../../../core/media/image_storage_service.dart';
import '../../../core/store/store_branding.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/store_settings_provider.dart';
import '../domain/pos_state.dart';
import '../domain/pos_tax.dart';

/// Builds a receipt PDF for preview or printing.
Future<Uint8List> buildSaleReceiptPdfBytes({
  required StoreSetting? settings,
  required PosState cartState,
  required String paymentSummary,
  String? saleId,
  PosTaxCalculator? tax,
  DateTime? createdAt,
}) async {
  final taxCalc = tax ??
      PosTaxCalculator(
        taxRateBps: settings?.taxRateBps,
        taxInclusive: settings?.taxInclusive ?? false,
        taxName: settings?.taxName,
      );
  final storeName = StoreBranding.displayName(settings);
  final header = settings?.receiptHeader;
  final currency = settings?.currencyCode ?? 'USD';
  final fmt = DateFormat('yyyy-MM-dd HH:mm');

  String money(int cents) => formatMoney(cents, currency: currency);

  final logoBytes = await ImageStorageService.loadLogoBytes(
    localPath: settings?.logoLocalPath,
    remoteUrl: StoreBranding.logoRemoteForLoad(settings),
  );
  pw.Widget? logoWidget;
  if (logoBytes != null && logoBytes.isNotEmpty) {
    logoWidget = pw.Center(
      child: pw.Image(
        pw.MemoryImage(Uint8List.fromList(logoBytes)),
        width: 56,
        height: 56,
        fit: pw.BoxFit.contain,
      ),
    );
  }

  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoWidget != null) ...[
              logoWidget,
              pw.SizedBox(height: 6),
            ],
            pw.Text(
              storeName,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
            if (settings?.phone != null && settings!.phone!.isNotEmpty) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                settings.phone!,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
            if (header != null && header.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                header,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
            if (settings?.address != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                settings!.address!,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
            pw.SizedBox(height: 8),
            pw.Text(
              fmt.format(createdAt ?? DateTime.now()),
              style: const pw.TextStyle(fontSize: 9),
            ),
            if (saleId != null)
              pw.Text(
                'Sale #${saleId.substring(0, 8)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
            pw.Divider(),
            ...cartState.cart.map(
              (i) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            i.name,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            '${i.quantity} x ${money(i.unitPriceCents)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      money(i.lineTotalCents),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            pw.Divider(),
            _receiptLine('Subtotal', money(cartState.subtotalCents)),
            if (cartState.orderDiscountCents > 0)
              _receiptLine(
                'Discount',
                '-${money(cartState.orderDiscountCents)}',
              ),
            if (cartState.taxCents > 0) _receiptLine('Tax', money(cartState.taxCents)),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  money(cartState.totalCents(taxCalc)),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Paid: $paymentSummary',
              style: const pw.TextStyle(fontSize: 9),
            ),
            if (cartState.customerName != null)
              pw.Text(
                'Customer: ${cartState.customerName}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            if (settings?.invoiceFooter != null &&
                settings!.invoiceFooter!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                settings.invoiceFooter!.trim(),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
            pw.SizedBox(height: 12),
            pw.Text(
              'Thank you!',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

/// Prints a sale receipt (thermal roll or standard printer).
Future<void> printSaleReceipt({
  required StoreSetting? settings,
  required PosState cartState,
  required String paymentSummary,
  String? saleId,
  PosTaxCalculator? tax,
}) async {
  final bytes = await buildSaleReceiptPdfBytes(
    settings: settings,
    cartState: cartState,
    paymentSummary: paymentSummary,
    saleId: saleId,
    tax: tax,
  );
  await Printing.layoutPdf(
    onLayout: (_) async => bytes,
    name: 'receipt_${saleId ?? DateTime.now().millisecondsSinceEpoch}',
  );
}

pw.Widget _receiptLine(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );

/// Brief scan-success flash at top of POS.
void showPosScanFlash(BuildContext context, String productName) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Added: $productName',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.accent,
      duration: const Duration(milliseconds: 900),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    ),
  );
}
