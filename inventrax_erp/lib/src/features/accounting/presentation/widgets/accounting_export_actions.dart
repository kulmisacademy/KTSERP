import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/media/branded_pdf_header.dart';
import '../../../../data/local/store_settings_provider.dart';
import '../../services/accounting_pdf_service.dart';

class AccountingExportButton extends ConsumerWidget {
  const AccountingExportButton({
    super.key,
    required this.filename,
    required this.buildPdf,
    this.showLabel = false,
  });

  final String filename;
  final Future<List<int>> Function(AccountingPdfService service) buildPdf;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final onExport = () => _export(context, ref);

    if (showLabel) {
      return OutlinedButton.icon(
        onPressed: onExport,
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: Text(l10n.acctExportPdf),
      );
    }

    return IconButton(
      tooltip: l10n.acctExportPdf,
      icon: const Icon(Icons.picture_as_pdf_outlined),
      onPressed: onExport,
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
        try {
          final settings = ref.read(storeSettingsProvider).value;
          final branding = await StoreBrandingPdf.fromSettings(settings);
          final service = AccountingPdfService(branding: branding);
          final bytes = await buildPdf(service);
          if (!context.mounted) return;
          await Printing.sharePdf(
            bytes: Uint8List.fromList(bytes),
            filename: filename,
          );
        } catch (e) {
          if (context.mounted) {
            final l10n = context.l10n;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.acctExportFailed(e.toString()))),
            );
          }
        }
  }
}

String accountingStoreLabel(WidgetRef ref) {
  return ref.watch(storeDisplayNameProvider);
}
