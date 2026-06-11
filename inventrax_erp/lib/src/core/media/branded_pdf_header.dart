import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/store/store_branding.dart';
import '../../data/local/app_database.dart';
import 'image_storage_service.dart';

/// Store branding block for A4 PDF exports (reports, accounting).
class StoreBrandingPdf {
  const StoreBrandingPdf({
    required this.storeName,
    this.phone,
    this.address,
    this.email,
    this.taxNumber,
    this.invoiceFooter,
    this.logoBytes,
  });

  final String storeName;
  final String? phone;
  final String? address;
  final String? email;
  final String? taxNumber;
  final String? invoiceFooter;
  final List<int>? logoBytes;

  static Future<StoreBrandingPdf> fromSettings(StoreSetting? settings) async {
    final logoBytes = await ImageStorageService.loadLogoBytes(
      localPath: settings?.logoLocalPath,
      remoteUrl: StoreBranding.logoRemoteForLoad(settings),
    );
    return StoreBrandingPdf(
      storeName: StoreBranding.displayName(settings),
      phone: settings?.phone,
      address: settings?.address,
      email: settings?.email,
      taxNumber: settings?.taxNumber,
      invoiceFooter: settings?.invoiceFooter,
      logoBytes: logoBytes,
    );
  }

  pw.Widget buildHeader(
    String reportTitle, {
    String? subtitle,
    DateTime? asOf,
  }) {
    final contact = <String>[
      if (phone != null && phone!.trim().isNotEmpty) phone!.trim(),
      if (email != null && email!.trim().isNotEmpty) email!.trim(),
      if (address != null && address!.trim().isNotEmpty) address!.trim(),
      if (taxNumber != null && taxNumber!.trim().isNotEmpty)
        'Tax: ${taxNumber!.trim()}',
    ];

    pw.Widget? logo;
    if (logoBytes != null && logoBytes!.isNotEmpty) {
      logo = pw.Image(
        pw.MemoryImage(Uint8List.fromList(logoBytes!)),
        width: 48,
        height: 48,
        fit: pw.BoxFit.contain,
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (logo != null) ...[
          logo,
          pw.SizedBox(width: 12),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                storeName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (contact.isNotEmpty)
                pw.Text(
                  contact.join(' • '),
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              pw.SizedBox(height: 6),
              pw.Text(
                reportTitle,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9)),
              if (asOf != null)
                pw.Text(
                  'As of $asOf',
                  style: const pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget? buildFooter() {
    final text = invoiceFooter?.trim();
    if (text == null || text.isEmpty) return null;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }
}
