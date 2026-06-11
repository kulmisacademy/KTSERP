import 'app_database.dart';

/// Catalog list filters (applied in SQL, not in memory).
enum ProductListFilter { all, lowStock, outOfStock }

/// Cursor for keyset pagination (stable under inserts; better than OFFSET at scale).
class ProductPageCursor {
  const ProductPageCursor({
    required this.updatedAt,
    required this.id,
  });

  final DateTime updatedAt;
  final String id;
}

class ProductSearchPage {
  const ProductSearchPage({
    required this.items,
    this.nextCursor,
  });

  final List<Product> items;
  final ProductPageCursor? nextCursor;

  bool get hasMore => nextCursor != null;
}

class ProductInventoryCounts {
  const ProductInventoryCounts({
    required this.total,
    required this.lowStock,
    required this.outOfStock,
  });

  final int total;
  final int lowStock;
  final int outOfStock;
}

class DailySalesMetric {
  const DailySalesMetric({required this.day, required this.totalCents});

  final DateTime day;
  final int totalCents;
}

class DashboardMetricsSnapshot {
  const DashboardMetricsSnapshot({
    required this.todaySalesCents,
    required this.monthSalesCents,
    required this.todayExpensesCents,
    required this.monthExpensesCents,
    required this.monthCogsCents,
    required this.monthProfitCents,
    required this.salesTrend,
  });

  final int todaySalesCents;
  final int monthSalesCents;
  final int todayExpensesCents;
  final int monthExpensesCents;
  final int monthCogsCents;
  final int monthProfitCents;
  final List<DailySalesMetric> salesTrend;
}
