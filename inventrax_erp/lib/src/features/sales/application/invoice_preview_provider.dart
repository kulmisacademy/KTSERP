import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/invoice_branding.dart';
import '../domain/sale_invoice_data.dart';
import 'invoice_branding_provider.dart';
import 'sale_invoice_provider.dart';

/// Combined sale invoice data + live branding for modal preview.
final invoicePreviewProvider = FutureProvider.autoDispose
    .family<({SaleInvoiceData data, InvoiceBranding branding}), String>(
  (ref, saleId) async {
    final data = await ref.watch(saleInvoiceProvider(saleId).future);
    final branding = ref.watch(invoiceBrandingProvider);
    return (data: data, branding: branding);
  },
);
