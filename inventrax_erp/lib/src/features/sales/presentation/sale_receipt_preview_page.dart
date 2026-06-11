import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../pos/domain/pos_models.dart';
import '../../pos/domain/pos_state.dart';
import '../../pos/domain/pos_tax.dart';
import '../../pos/presentation/pos_receipt.dart';
import '../../../ui/layout/app_shell.dart';

class SaleReceiptPreviewPage extends ConsumerWidget {
  const SaleReceiptPreviewPage({super.key, required this.saleId});

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final settings = ref.watch(storeSettingsProvider);

    return AppShell(
      title: 'Receipt',
      subtitle: 'Sale #${saleId.substring(0, 8)}',
      child: FutureBuilder<({Sale sale, List<SaleItem> items})>(
        future: () async {
          final sale = await db.getSaleById(
            storeId: StoreContext.storeId,
            saleId: saleId,
          );
          if (sale == null) {
            throw StateError('Sale not found');
          }
          final items = await db.listSaleItems(
            storeId: StoreContext.storeId,
            saleId: saleId,
          );
          return (sale: sale, items: items);
        }(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final sale = snap.data!.sale;
          final items = snap.data!.items;

          final cart = items
              .map(
                (i) => PosCartItem(
                  productId: i.productId ?? i.id,
                  name: i.name,
                  barcode: i.barcode,
                  unitPriceCents: i.unitPriceCents,
                  unitCostCents: i.unitCostCents,
                  catalogPriceCents: i.unitPriceCents,
                  quantity: i.quantity,
                  isDirectSale: i.productId == null,
                ),
              )
              .toList();

          final cartState = PosState(
            cart: cart,
            orderDiscountCents: sale.discountCents,
            taxCents: sale.taxCents,
            customerId: sale.customerId,
            customerName: null,
            notes: sale.notes,
          );

          final tax = PosTaxCalculator(
            taxRateBps: settings.value?.taxRateBps,
            taxInclusive: settings.value?.taxInclusive ?? false,
            taxName: settings.value?.taxName,
          );

          return PdfPreview(
            canChangePageFormat: false,
            canChangeOrientation: false,
            allowPrinting: true,
            allowSharing: true,
            build: (format) async {
              // paymentJson is stored as a JSON string; present a friendly label.
              final paymentSummary = () {
                try {
                  final m = jsonDecode(sale.paymentJson);
                  if (m is Map) {
                    final method = m['method']?.toString();
                    if (method == 'split') return 'Split';
                    if (method != null && method.isNotEmpty) return method;
                  }
                } catch (_) {}
                return 'Payment';
              }();

              return buildSaleReceiptPdfBytes(
                settings: settings.value,
                cartState: cartState,
                paymentSummary: paymentSummary,
                saleId: sale.id,
                tax: tax,
                createdAt: sale.createdAt,
              );
            },
          );
        },
      ),
    );
  }
}

