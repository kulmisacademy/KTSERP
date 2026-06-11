import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/store/active_store_scope.dart';
import '../../data/local/app_database.dart';
import '../../data/local/db_provider.dart';
import '../../data/local/product_search.dart';

/// Local Drift aggregates — cache-first; never blocks on cloud sync.
final dashboardMetricsProvider =
    FutureProvider.autoDispose<DashboardMetricsSnapshot>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.fetchDashboardMetrics(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
  );
});

/// Sales + expense KPI cards (independent of trend / inventory widgets).
final salesMetricsProvider =
    FutureProvider.autoDispose<DashboardKpis>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return DashboardKpis(
    todaySalesCents: metrics.todaySalesCents,
    monthSalesCents: metrics.monthSalesCents,
    todayExpensesCents: metrics.todayExpensesCents,
    monthExpensesCents: metrics.monthExpensesCents,
    monthProfitCents: metrics.monthProfitCents,
  );
});

final dashboardKpisProvider = salesMetricsProvider;

final salesTrendProvider =
    FutureProvider.autoDispose<List<DailySalesPoint>>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  final metrics = await db.fetchDashboardMetrics(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
  );
  final dayLabel = DateFormat.E();
  return [
    for (final point in metrics.salesTrend)
      DailySalesPoint(
        label: dayLabel.format(point.day),
        amount: point.totalCents / 100,
      ),
  ];
});

/// Low-stock inventory slice — does not block sales KPI providers.
final inventoryMetricsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.listLowStockProducts(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
    limit: 6,
  );
});

final lowStockProvider = inventoryMetricsProvider;

/// Debt alert counts — independent provider for dashboard banner.
final alertsProvider = dashboardDebtAlertsProvider;

final recentSalesProvider = FutureProvider.autoDispose<List<Sale>>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.listRecentSales(
    tenantId: scope.tenantId,
    storeId: scope.storeId,
    limit: 6,
  );
});

class DashboardDebtAlerts {
  const DashboardDebtAlerts({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.upcomingCount,
  });

  final int overdueCount;
  final int dueTodayCount;
  final int upcomingCount;

  bool get hasAlerts =>
      overdueCount > 0 || dueTodayCount > 0 || upcomingCount > 0;
}

final dashboardDebtAlertsProvider =
    FutureProvider.autoDispose<DashboardDebtAlerts>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  final storeId = scope.storeId;
  if (storeId.isEmpty || storeId == 'dev-store') {
    return const DashboardDebtAlerts(
      overdueCount: 0,
      dueTodayCount: 0,
      upcomingCount: 0,
    );
  }
  final overdue = await db.countOverdueDebts(storeId: storeId);
  final today = await db.countDebtsDueToday(storeId: storeId);
  final upcoming = await db.countDebtsUpcoming(storeId: storeId);
  return DashboardDebtAlerts(
    overdueCount: overdue,
    dueTodayCount: today,
    upcomingCount: upcoming,
  );
});

class DashboardKpis {
  const DashboardKpis({
    required this.todaySalesCents,
    required this.monthSalesCents,
    required this.todayExpensesCents,
    required this.monthExpensesCents,
    required this.monthProfitCents,
  });

  final int todaySalesCents;
  final int monthSalesCents;
  final int todayExpensesCents;
  final int monthExpensesCents;
  final int monthProfitCents;
}

class DailySalesPoint {
  const DailySalesPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

/// Refreshes dashboard aggregates after local writes (sale, expense, etc.).
void invalidateDashboardMetrics(WidgetRef ref) {
  ref.invalidate(dashboardMetricsProvider);
  ref.invalidate(recentSalesProvider);
  ref.invalidate(dashboardDebtAlertsProvider);
}

/// For [Notifier] / [Ref] contexts (e.g. POS controller).
void invalidateDashboardMetricsFrom(Ref ref) {
  ref.invalidate(dashboardMetricsProvider);
  ref.invalidate(recentSalesProvider);
  ref.invalidate(dashboardDebtAlertsProvider);
}
