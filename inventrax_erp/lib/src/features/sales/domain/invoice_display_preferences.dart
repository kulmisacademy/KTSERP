import 'package:flutter/material.dart' show FlexColumnWidth;
import 'package:pdf/widgets.dart' as pw;

import '../../../data/local/app_database.dart';

/// Presentation-only invoice column/row visibility (calculations unchanged).
class InvoiceDisplayPreferences {
  const InvoiceDisplayPreferences({
    this.showSku = false,
    this.showDiscount = false,
    this.showTax = false,
    this.compactMode = true,
  });

  final bool showSku;
  final bool showDiscount;
  final bool showTax;
  final bool compactMode;

  /// Clean invoice — hide SKU, discount, and tax columns/rows.
  static const compact = InvoiceDisplayPreferences();

  /// Full detail — show all columns and breakdown rows.
  static const detailed = InvoiceDisplayPreferences(
    showSku: true,
    showDiscount: true,
    showTax: true,
    compactMode: false,
  );

  factory InvoiceDisplayPreferences.fromStore(StoreSetting? settings) {
    if (settings == null) return compact;
    return InvoiceDisplayPreferences(
      showSku: settings.invoiceShowSku,
      showDiscount: settings.invoiceShowDiscount,
      showTax: settings.invoiceShowTax,
      compactMode: settings.invoiceCompactMode,
    );
  }

  InvoiceDisplayPreferences copyWith({
    bool? showSku,
    bool? showDiscount,
    bool? showTax,
    bool? compactMode,
  }) {
    return InvoiceDisplayPreferences(
      showSku: showSku ?? this.showSku,
      showDiscount: showDiscount ?? this.showDiscount,
      showTax: showTax ?? this.showTax,
      compactMode: compactMode ?? this.compactMode,
    );
  }

  InvoiceDisplayPreferences applyPreset({required bool detailedMode}) {
    return detailedMode ? InvoiceDisplayPreferences.detailed : compact;
  }

  Map<String, dynamic> toJson() => {
        'showSku': showSku,
        'showDiscount': showDiscount,
        'showTax': showTax,
        'compactMode': compactMode,
      };

  factory InvoiceDisplayPreferences.fromJson(Map<String, dynamic>? m) {
    if (m == null) return compact;
    return InvoiceDisplayPreferences(
      showSku: m['showSku'] as bool? ?? false,
      showDiscount: m['showDiscount'] as bool? ?? false,
      showTax: m['showTax'] as bool? ?? false,
      compactMode: m['compactMode'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is InvoiceDisplayPreferences &&
      showSku == other.showSku &&
      showDiscount == other.showDiscount &&
      showTax == other.showTax &&
      compactMode == other.compactMode;

  @override
  int get hashCode => Object.hash(showSku, showDiscount, showTax, compactMode);
}

/// Dynamic invoice table columns — only visible columns are rendered.
enum InvoiceTableColumn { product, sku, qty, unitPrice, discount, tax, lineTotal }

abstract final class InvoiceTableLayout {
  static const _baseFlex = <InvoiceTableColumn, double>{
    InvoiceTableColumn.product: 2.4,
    InvoiceTableColumn.sku: 1.2,
    InvoiceTableColumn.qty: 0.6,
    InvoiceTableColumn.unitPrice: 1.0,
    InvoiceTableColumn.discount: 0.7,
    InvoiceTableColumn.tax: 0.7,
    InvoiceTableColumn.lineTotal: 1.0,
  };

  static List<InvoiceTableColumn> visibleColumns(InvoiceDisplayPreferences prefs) {
    return [
      InvoiceTableColumn.product,
      if (prefs.showSku) InvoiceTableColumn.sku,
      InvoiceTableColumn.qty,
      InvoiceTableColumn.unitPrice,
      if (prefs.showDiscount) InvoiceTableColumn.discount,
      if (prefs.showTax) InvoiceTableColumn.tax,
      InvoiceTableColumn.lineTotal,
    ];
  }

  static double flexFor(InvoiceTableColumn col, InvoiceDisplayPreferences prefs) {
    var flex = _baseFlex[col] ?? 1.0;
    if (col == InvoiceTableColumn.product && !prefs.showSku) {
      flex += _baseFlex[InvoiceTableColumn.sku] ?? 0;
    }
    return flex;
  }

  static Map<int, FlexColumnWidth> flutterColumnWidths(
    InvoiceDisplayPreferences prefs,
  ) {
    final cols = visibleColumns(prefs);
    return {
      for (var i = 0; i < cols.length; i++)
        i: FlexColumnWidth(flexFor(cols[i], prefs)),
    };
  }

  static Map<int, pw.FlexColumnWidth> pdfColumnWidths(
    InvoiceDisplayPreferences prefs,
  ) {
    final cols = visibleColumns(prefs);
    return {
      for (var i = 0; i < cols.length; i++)
        i: pw.FlexColumnWidth(flexFor(cols[i], prefs)),
    };
  }

  static List<String> headerLabels(
    InvoiceDisplayPreferences prefs, {
    required String product,
    required String sku,
    required String qty,
    required String unitPrice,
    required String discount,
    required String tax,
    required String lineTotal,
  }) {
    return visibleColumns(prefs).map((c) => switch (c) {
          InvoiceTableColumn.product => product,
          InvoiceTableColumn.sku => sku,
          InvoiceTableColumn.qty => qty,
          InvoiceTableColumn.unitPrice => unitPrice,
          InvoiceTableColumn.discount => discount,
          InvoiceTableColumn.tax => tax,
          InvoiceTableColumn.lineTotal => lineTotal,
        }).toList();
  }
}
