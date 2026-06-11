import 'package:flutter/foundation.dart' show Uint8List;

import '../../../data/local/app_database.dart';
import '../domain/invoice_branding.dart';
import '../domain/invoice_display_preferences.dart';
import '../domain/invoice_document.dart';
import '../domain/sale_invoice_data.dart';
import 'invoice_document_pdf.dart';

/// Builds A4 PDF bytes — uses shared [InvoiceDocument] template (matches preview UI).
Future<Uint8List> buildSaleInvoicePdfBytes({
  required SaleInvoiceData data,
  StoreSetting? settings,
  InvoiceBranding? branding,
  InvoiceDisplayPreferences display = InvoiceDisplayPreferences.compact,
  String localeCode = 'en',
  bool compact = true,
}) async {
  final doc = InvoiceDocument.fromSale(
    data: data,
    branding: branding ?? InvoiceBranding.fromSettings(settings),
    display: display,
  );
  return buildInvoiceDocumentPdf(
    doc: doc,
    settings: settings,
    localeCode: localeCode,
    compact: compact,
  );
}
