import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../data/local/store_settings_provider.dart';
import '../../sales/application/invoice_branding_provider.dart';
import '../../sales/application/invoice_display_provider.dart';
import '../../sales/domain/invoice_document.dart';
import '../../sales/domain/sale_invoice_data.dart';
import '../../sales/presentation/widgets/invoice_display_controls.dart';
import '../../sales/presentation/widgets/sale_invoice_view.dart';
import '../../sales/services/invoice_document_pdf.dart';
import '../application/custom_sales_controller.dart';
import '../application/custom_sales_totals_provider.dart';
import '../domain/custom_sales_models.dart';

const _previewSessionKey = 'custom-sales-preview';

/// Shows draft invoice in the same premium modal shell (preview before save).
Future<void> showCustomSalesInvoicePreview(
  BuildContext context,
  WidgetRef ref,
  CustomSalesState state,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close preview',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: const _DraftPreviewShell(),
        ),
      );
    },
  );
}

class _DraftPreviewShell extends ConsumerWidget {
  const _DraftPreviewShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSalesControllerProvider);
    final settings = ref.watch(storeSettingsProvider).value;
    final branding = ref.watch(invoiceBrandingProvider);
    final tax = ref.watch(posTaxProvider);
    final breakdown = ref.watch(customSalesTotalsProvider);
    final display = effectiveInvoiceDisplay(
      ref,
      _previewSessionKey,
      draftPrefs: state.displayPrefs,
    );

    final doc = InvoiceDocument.fromCustomSales(
      state: state,
      branding: branding,
      taxCalculator: tax,
      currencyCode: settings?.currencyCode ?? 'USD',
      taxName: settings?.taxName,
      display: display,
    );
    final data = SaleInvoiceData.fromDocument(doc);
    final locale = Localizations.localeOf(context).languageCode;

    final size = MediaQuery.sizeOf(context);
    final modalHeight = (size.height * 0.9).clamp(480.0, size.height * 0.92);
    final modalWidth = (size.width - 32).clamp(320.0, 1100.0);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black.withValues(alpha: 0.38)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: modalWidth,
                height: modalHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Invoice Preview',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF041F4A),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Export PDF',
                                  onPressed: () async {
                                    final bytes = await buildInvoiceDocumentPdf(
                                      doc: doc,
                                      settings: settings,
                                      localeCode: locale,
                                    );
                                    await Printing.sharePdf(
                                      bytes: bytes,
                                      filename: 'invoice-${doc.invoiceNumber}.pdf',
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf_outlined),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            InvoiceDisplayControls(
                              display: display,
                              onChanged: (d) {
                                ref
                                    .read(invoiceDisplayOverridesProvider.notifier)
                                    .setOverride(_previewSessionKey, d);
                                ref
                                    .read(customSalesControllerProvider.notifier)
                                    .setDisplayPreferences(d);
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          child: SaleInvoiceView(
                            data: data,
                            branding: branding,
                            compact: true,
                            totalsBreakdown: breakdown,
                            display: display,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
