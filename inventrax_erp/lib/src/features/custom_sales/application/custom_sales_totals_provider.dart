import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/store_settings_provider.dart';
import '../../sales/domain/invoice_totals_engine.dart';
import 'custom_sales_controller.dart';

final customSalesTotalsProvider = Provider<InvoiceTotalsBreakdown>((ref) {
  final state = ref.watch(customSalesControllerProvider);
  final tax = ref.watch(posTaxProvider);
  return InvoiceTotalsEngine.compute(
    lines: state.lines,
    invoiceDiscount: state.invoiceDiscount,
    taxCalculator: tax,
    taxEnabled: state.taxEnabled,
  );
});
