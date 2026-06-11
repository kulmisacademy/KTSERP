import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/app_database.dart';
import '../domain/barcode_service.dart';

enum LabelSize {
  small('40×30 mm', widthMm: 40, heightMm: 30),
  medium('80 mm roll', widthMm: 80, heightMm: 50),
  large('A6', widthMm: 105, heightMm: 148);

  const LabelSize(this.label, {required this.widthMm, required this.heightMm});
  final String label;
  final double widthMm;
  final double heightMm;

  PdfPageFormat get pageFormat => PdfPageFormat(
        widthMm * PdfPageFormat.mm,
        heightMm * PdfPageFormat.mm,
        marginAll: 2 * PdfPageFormat.mm,
      );
}

Future<void> printProductBarcodeLabel(
  BuildContext context, {
  required Product product,
  required String storeName,
  BarcodeSymbology symbology = BarcodeSymbology.code128,
  LabelSize labelSize = LabelSize.medium,
}) async {
  final barcode = product.barcode;
  if (barcode == null || barcode.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.barcodeNoBarcode)),
    );
    return;
  }

  final pdf = pw.Document();
  final bc = switch (symbology) {
    BarcodeSymbology.ean13 => pw.Barcode.ean13(),
    BarcodeSymbology.qr => pw.Barcode.qrCode(),
    BarcodeSymbology.code128 => pw.Barcode.code128(),
  };

  pdf.addPage(
    pw.Page(
      pageFormat: labelSize.pageFormat,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(storeName, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(
            product.name,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.BarcodeWidget(
            barcode: bc,
            data: barcode,
            width: 180,
            height: 50,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            (product.sellingPriceCents / 100).toStringAsFixed(2),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (_) async => pdf.save(),
    name: 'label_${product.id}',
  );
}

void showBarcodeLabelPreview(BuildContext context, Product product, String storeName) {
  final barcode = product.barcode;
  if (barcode == null) return;

  var size = LabelSize.medium;
  final sym = switch (product.barcodeType) {
    'ean13' => BarcodeSymbology.ean13,
    'qr' => BarcodeSymbology.qr,
    _ => BarcodeSymbology.code128,
  };

  showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      return StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l10n.barcodeLabelTitle),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LabelSize>(
                value: size,
                decoration: const InputDecoration(labelText: 'Label size'),
                items: LabelSize.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => size = v ?? size),
              ),
              const SizedBox(height: 8),
              Text(storeName, style: Theme.of(ctx).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(product.name, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              bw.BarcodeWidget(
                barcode: switch (sym) {
                  BarcodeSymbology.ean13 => bw.Barcode.ean13(),
                  BarcodeSymbology.qr => bw.Barcode.qrCode(),
                  BarcodeSymbology.code128 => bw.Barcode.code128(),
                },
                data: barcode,
                width: 240,
                height: 64,
              ),
              const SizedBox(height: 8),
              Text(
                (product.sellingPriceCents / 100).toStringAsFixed(2),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonClose),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              printProductBarcodeLabel(
                context,
                product: product,
                storeName: storeName,
                symbology: sym,
                labelSize: size,
              );
            },
            child: Text(l10n.commonPrint),
          ),
        ],
      ),
    );
    },
  );
}
