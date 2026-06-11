import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../data/local/app_database.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../application/invoice_display_provider.dart';
import '../../application/invoice_preview_provider.dart';
import '../../domain/invoice_branding.dart';
import '../../domain/invoice_display_preferences.dart';
import '../../domain/sale_invoice_data.dart';
import '../../services/sale_invoice_pdf_service.dart';
import 'invoice_display_controls.dart';
import 'sale_invoice_view.dart';

const _modalMaxWidth = 1100.0;

/// Opens invoice as a centered modal with blurred backdrop (Shopify/Stripe-style).
Future<void> showSaleInvoiceModal(
  BuildContext context,
  WidgetRef ref,
  String saleId,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close invoice',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: _SaleInvoiceModalShell(saleId: saleId),
        ),
      );
    },
  );
}

class _SaleInvoiceModalShell extends ConsumerWidget {
  const _SaleInvoiceModalShell({required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final modalHeight = (size.height * 0.9).clamp(480.0, size.height * 0.92);
    final modalWidth = (size.width - 32).clamp(320.0, _modalMaxWidth);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withValues(alpha: 0.38)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: modalWidth,
                height: modalHeight,
                child: _SaleInvoiceModalContent(saleId: saleId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleInvoiceModalContent extends ConsumerWidget {
  const _SaleInvoiceModalContent({required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final preview = ref.watch(invoicePreviewProvider(saleId));
    final settings = ref.watch(storeSettingsProvider).value;
    final display = effectiveInvoiceDisplay(ref, saleId);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop();
        },
      },
      child: Focus(
        autofocus: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF041F4A).withValues(alpha: 0.18),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InvoiceToolbar(
                  saleId: saleId,
                  preview: preview,
                  settings: settings,
                  locale: locale,
                  display: display,
                  onDisplayChanged: (d) => ref
                      .read(invoiceDisplayOverridesProvider.notifier)
                      .setOverride(saleId, d),
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: preview.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (bundle) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: SaleInvoiceView(
                        data: bundle.data,
                        branding: bundle.branding,
                        compact: true,
                        display: display,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceToolbar extends StatelessWidget {
  const _InvoiceToolbar({
    required this.saleId,
    required this.preview,
    required this.settings,
    required this.locale,
    required this.display,
    required this.onDisplayChanged,
    required this.onClose,
  });

  final String saleId;
  final AsyncValue<({SaleInvoiceData data, InvoiceBranding branding})> preview;
  final StoreSetting? settings;
  final String locale;
  final InvoiceDisplayPreferences display;
  final ValueChanged<InvoiceDisplayPreferences> onDisplayChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bundle = preview.value;
    final data = bundle?.data;
    final branding = bundle?.branding;

    return Material(
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.invoiceTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF041F4A),
                        ),
                      ),
                      if (data != null)
                        Text(
                          '${l10n.invoiceNumber}${data.invoiceNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (data != null && branding != null) ...[
              const SizedBox(height: 8),
              InvoiceDisplayControls(
                display: display,
                onChanged: onDisplayChanged,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ToolbarButton(
                    icon: Icons.print_outlined,
                    label: l10n.invoicePrint,
                    onPressed: () => _print(context, data, branding, display),
                  ),
                  _ToolbarButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: l10n.invoiceSharePdf,
                    onPressed: () => _sharePdf(data, branding, display),
                  ),
                  _ToolbarButton(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.invoiceOpenThermal,
                    outlined: true,
                    onPressed: () {
                      onClose();
                      context.push('/sales/$saleId/receipt');
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _print(
    BuildContext context,
    SaleInvoiceData data,
    InvoiceBranding branding,
    InvoiceDisplayPreferences display,
  ) async {
    await Printing.layoutPdf(
      name: 'invoice-${data.invoiceNumber}',
      format: PdfPageFormat.a4,
      onLayout: (_) => buildSaleInvoicePdfBytes(
        data: data,
        settings: settings,
        branding: branding,
        display: display,
        localeCode: locale,
      ),
    );
  }

  Future<void> _sharePdf(
    SaleInvoiceData data,
    InvoiceBranding branding,
    InvoiceDisplayPreferences display,
  ) async {
    final bytes = await buildSaleInvoicePdfBytes(
      data: data,
      settings: settings,
      branding: branding,
      display: display,
      localeCode: locale,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice-${data.invoiceNumber}.pdf',
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(label),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: VisualDensity.compact,
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
      ),
      child: child,
    );
  }
}
