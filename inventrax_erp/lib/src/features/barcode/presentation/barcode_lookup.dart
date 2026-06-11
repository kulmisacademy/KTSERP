import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import 'barcode_not_found_dialog.dart';
import 'barcode_scanner_page.dart';
import 'quick_product_sheet.dart';

/// Resolves a barcode to a product: lookup, scan hit, or new-product sheet.
class BarcodeLookup {
  BarcodeLookup(this._db);

  final AppDatabase _db;

  Future<Product?> resolve(
    BuildContext context, {
    required String rawBarcode,
    bool allowCreate = true,
    bool allowDirectSale = false,
    void Function(String barcode)? onDirectSale,
  }) async {
    final code = rawBarcode.trim();
    if (code.isEmpty) return null;

    var product = await _db.findProductByBarcodeFast(
      storeId: StoreContext.storeId,
      barcode: code,
    );

    if (product != null) {
      unawaited(
        _db.recordScanHit(productId: product.id, storeId: StoreContext.storeId),
      );
      HapticFeedback.mediumImpact();
      return product;
    }

    if (!context.mounted) return null;

    final action = await showBarcodeNotFoundDialog(
      context,
      barcode: code,
      allowDirectSale: allowDirectSale,
    );

    if (!context.mounted) return null;

    switch (action) {
      case BarcodeNotFoundAction.addNew:
        if (!allowCreate) return null;
        return showQuickProductSheet(context, barcode: code);
      case BarcodeNotFoundAction.retry:
        final rescanned = await scanBarcodeWithCamera(context);
        if (rescanned != null) {
          return resolve(
            context,
            rawBarcode: rescanned,
            allowCreate: allowCreate,
            allowDirectSale: allowDirectSale,
            onDirectSale: onDirectSale,
          );
        }
        return null;
      case BarcodeNotFoundAction.directSale:
        onDirectSale?.call(code);
        return null;
      case BarcodeNotFoundAction.manual:
      case BarcodeNotFoundAction.cancel:
      case null:
        return null;
    }
  }
}

BarcodeLookup barcodeLookup(WidgetRef ref) =>
    BarcodeLookup(ref.read(appDatabaseProvider));
