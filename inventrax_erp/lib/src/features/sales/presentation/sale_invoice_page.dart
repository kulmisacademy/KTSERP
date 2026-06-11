import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'sales_history_page.dart';
import 'widgets/sale_invoice_modal.dart';

/// Deep-link handler — opens invoice modal over sales list, returns on close.
class SaleInvoicePage extends ConsumerStatefulWidget {
  const SaleInvoicePage({super.key, required this.saleId});

  final String saleId;

  @override
  ConsumerState<SaleInvoicePage> createState() => _SaleInvoicePageState();
}

class _SaleInvoicePageState extends ConsumerState<SaleInvoicePage> {
  var _opened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openModal());
  }

  Future<void> _openModal() async {
    if (_opened || !mounted) return;
    _opened = true;
    await showSaleInvoiceModal(context, ref, widget.saleId);
    if (mounted) context.go('/sales');
  }

  @override
  Widget build(BuildContext context) {
    return const SalesHistoryPage();
  }
}
