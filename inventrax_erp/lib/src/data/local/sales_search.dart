import 'app_database.dart';

/// Payment-centric filters for sales history.
enum SalesPaymentFilter {
  all,
  paid,
  partial,
  unpaid,
  refunded,
  voided,
}

enum SalesDatePreset {
  today,
  week,
  month,
  custom,
}

class SalePageCursor {
  const SalePageCursor({required this.createdAt, required this.id});

  final DateTime createdAt;
  final String id;
}

class SaleListEntry {
  const SaleListEntry({required this.sale, this.customerName});

  final Sale sale;
  final String? customerName;

  String get invoiceLabel =>
      sale.id.length >= 8 ? sale.id.substring(0, 8).toUpperCase() : sale.id;
}

class SaleSearchPage {
  const SaleSearchPage({required this.items, this.nextCursor});

  final List<SaleListEntry> items;
  final SalePageCursor? nextCursor;

  bool get hasMore => nextCursor != null;
}

class SalesHistorySummary {
  const SalesHistorySummary({
    required this.transactionCount,
    required this.netRevenueCents,
    required this.unpaidCount,
    required this.refundedCents,
  });

  final int transactionCount;
  final int netRevenueCents;
  final int unpaidCount;
  final int refundedCents;
}
