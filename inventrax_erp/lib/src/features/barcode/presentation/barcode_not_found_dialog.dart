import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extension.dart';

enum BarcodeNotFoundAction { cancel, retry, manual, addNew, directSale }

/// Standard "product not found" flow per PRD §16.
Future<BarcodeNotFoundAction?> showBarcodeNotFoundDialog(
  BuildContext context, {
  required String barcode,
  bool allowDirectSale = false,
}) {
  final l10n = context.l10n;
  return showDialog<BarcodeNotFoundAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.qr_code_scanner, size: 40),
      title: Text(l10n.barcodeProductNotFound),
      content: Text(l10n.barcodeNoMatch(barcode)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, BarcodeNotFoundAction.cancel),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, BarcodeNotFoundAction.manual),
          child: Text(l10n.manualEntry),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, BarcodeNotFoundAction.retry),
          child: Text(l10n.retryScan),
        ),
        if (allowDirectSale)
          TextButton(
            onPressed: () => Navigator.pop(ctx, BarcodeNotFoundAction.directSale),
            child: Text(l10n.barcodeDirectSale),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, BarcodeNotFoundAction.addNew),
          child: Text(l10n.barcodeAddNewProduct),
        ),
      ],
    ),
  );
}
