import 'package:drift/drift.dart' show Variable;
import 'package:intl/intl.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../domain/ai_models.dart';
import 'business_risk_detector.dart';

/// Aggregates local SQL metrics into a compact JSON payload for AI (never raw rows).
class BusinessAnalyticsAggregator {
  BusinessAnalyticsAggregator(this._db);

  final AppDatabase _db;

  Future<AiBusinessSnapshot> buildSnapshot({
    String? storeId,
    String? storeName,
    String? currency,
  }) async {
    final sid = storeId ?? StoreContext.storeId;
    final tid = StoreContext.tenantId;
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = now.month == 12
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    final startOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final last7Start = startOfToday.subtract(const Duration(days: 6));
    final prev7Start = last7Start.subtract(const Duration(days: 7));
    final thirtyDaysAgo = startOfToday.subtract(const Duration(days: 30));

    final results = await Future.wait([
      _db.sumSalesTotalCents(tenantId: tid, storeId: sid, from: startOfToday, to: startOfTomorrow),
      _db.sumSalesTotalCents(tenantId: tid, storeId: sid, from: startOfMonth, to: startOfNextMonth),
      _db.sumSalesTotalCents(tenantId: tid, storeId: sid, from: startOfPrevMonth, to: startOfMonth),
      _db.sumSalesTotalCents(tenantId: tid, storeId: sid, from: last7Start, to: startOfTomorrow),
      _db.sumSalesTotalCents(tenantId: tid, storeId: sid, from: prev7Start, to: last7Start),
      _db.sumExpensesCents(tenantId: tid, storeId: sid, from: startOfMonth, to: startOfNextMonth),
      _db.sumCogsCents(tenantId: tid, storeId: sid, from: startOfMonth, to: startOfNextMonth),
      _db.sumOpenCustomerReceivables(storeId: sid),
      _db.sumOpenSupplierPayables(storeId: sid),
      _db.countOverdueDebts(storeId: sid),
      _db.countProducts(tenantId: tid, storeId: sid),
      _db.sumSalesByDay(tenantId: tid, storeId: sid, from: last7Start, to: startOfTomorrow),
      _db.topSellingProducts(storeId: sid, from: startOfMonth, to: startOfNextMonth, limit: 8),
      _db.listLowStockProducts(tenantId: tid, storeId: sid, limit: 8),
      _fetchSlowMoving(sid, thirtyDaysAgo, startOfTomorrow),
      _fetchTopDebtors(sid),
      _fetchExpensesByCategory(sid, startOfMonth, startOfNextMonth),
      _fetchMonthPurchases(sid, startOfMonth, startOfNextMonth),
      _inventoryCounts(sid),
    ]);

    final monthSales = results[1] as int;
    final monthExpenses = results[5] as int;
    final monthCogs = results[6] as int;
    final trendByDay = results[11] as Map<DateTime, int>;
    final dayLabel = DateFormat.E();
    final trend7 = <AiTrendPoint>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(startOfToday.year, startOfToday.month, startOfToday.day - i);
      trend7.add(AiTrendPoint(label: dayLabel.format(day), cents: trendByDay[day] ?? 0));
    }

    final topRaw = results[12] as List<MapEntry<String, int>>;
    final lowStock = results[13] as List<Product>;
    final counts = results[18] as _InvCounts;

    return AiBusinessSnapshot(
      storeId: sid,
      storeName: storeName ?? StoreContext.storeName ?? 'Store',
      currency: currency ?? 'USD',
      generatedAt: now,
      todaySalesCents: results[0] as int,
      monthSalesCents: monthSales,
      prevMonthSalesCents: results[2] as int,
      last7SalesCents: results[3] as int,
      prev7SalesCents: results[4] as int,
      monthExpensesCents: monthExpenses,
      monthCogsCents: monthCogs,
      monthProfitCents: monthSales - monthCogs - monthExpenses,
      monthPurchasesCents: results[17] as int,
      customerReceivablesCents: results[7] as int,
      supplierPayablesCents: results[8] as int,
      overdueDebtCount: results[9] as int,
      productCount: results[10] as int,
      lowStockCount: counts.lowStock,
      outOfStockCount: counts.outOfStock,
      salesTrend7d: trend7,
      topProducts: topRaw
          .map((e) => AiProductRank(name: e.key, quantity: e.value))
          .toList(),
      lowStockProducts: lowStock
          .map((p) => AiProductRank(name: p.name, quantity: p.quantity))
          .toList(),
      slowMovingProducts: results[14] as List<AiProductRank>,
      topDebtors: results[15] as List<AiDebtorRank>,
      expensesByCategory: results[16] as List<AiExpenseCategory>,
    );
  }

  List<AiBusinessRisk> detectRisks(
    AiBusinessSnapshot s, {
    required AppLocalizations l10n,
  }) =>
      BusinessRiskDetector.analyze(l10n, s);

  Future<_InvCounts> _inventoryCounts(String storeId) async {
    final tid = StoreContext.tenantId;
    final low = await _db.listLowStockProducts(
      tenantId: tid,
      storeId: storeId,
      limit: 500,
    );
    final all = await _db.countProducts(tenantId: tid, storeId: storeId);
    final out = low.where((p) => p.quantity <= 0).length;
    return _InvCounts(lowStock: low.length, outOfStock: out, total: all);
  }

  Future<int> _fetchMonthPurchases(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final row = await _db.customSelect(
      '''
      SELECT COALESCE(SUM(total_cents), 0) AS total
      FROM purchases
      WHERE store_id = ? AND created_at >= ? AND created_at < ?
      ''',
      variables: [
        Variable<String>(storeId),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: {_db.purchases},
    ).getSingle();
    return row.read<int>('total');
  }

  Future<List<AiProductRank>> _fetchSlowMoving(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.customSelect(
      '''
      SELECT p.name, p.quantity
      FROM products p
      WHERE p.store_id = ? AND p.quantity > 0
        AND p.id NOT IN (
          SELECT DISTINCT si.product_id FROM sale_items si
          INNER JOIN sales s ON s.id = si.sale_id
          WHERE s.store_id = ? AND s.status != 'voided'
            AND s.created_at >= ? AND s.created_at < ?
            AND si.product_id IS NOT NULL
        )
      ORDER BY p.quantity DESC
      LIMIT 8
      ''',
      variables: [
        Variable<String>(storeId),
        Variable<String>(storeId),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: {_db.products, _db.saleItems, _db.sales},
    ).get();
    return rows
        .map(
          (r) => AiProductRank(
            name: r.read<String>('name'),
            quantity: r.read<int>('quantity'),
          ),
        )
        .toList();
  }

  Future<List<AiDebtorRank>> _fetchTopDebtors(String storeId) async {
    final rows = await _db.customSelect(
      '''
      SELECT COALESCE(c.name, 'Customer') AS name,
             SUM(d.remaining_cents) AS total
      FROM debts d
      LEFT JOIN customers c ON c.id = d.customer_id
      WHERE d.store_id = ? AND d.debt_type = 'customer'
        AND d.remaining_cents > 0
      GROUP BY d.customer_id
      ORDER BY total DESC
      LIMIT 5
      ''',
      variables: [Variable<String>(storeId)],
      readsFrom: {_db.debts, _db.customers},
    ).get();
    return rows
        .map(
          (r) => AiDebtorRank(
            name: r.read<String>('name'),
            remainingCents: r.read<int>('total'),
          ),
        )
        .toList();
  }

  Future<List<AiExpenseCategory>> _fetchExpensesByCategory(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.customSelect(
      '''
      SELECT category, COALESCE(SUM(amount_cents), 0) AS total
      FROM expenses
      WHERE store_id = ? AND expense_date >= ? AND expense_date < ?
      GROUP BY category
      ORDER BY total DESC
      LIMIT 8
      ''',
      variables: [
        Variable<String>(storeId),
        Variable<DateTime>(from),
        Variable<DateTime>(to),
      ],
      readsFrom: {_db.expenses},
    ).get();
    return rows
        .map(
          (r) => AiExpenseCategory(
            category: r.read<String>('category'),
            cents: r.read<int>('total'),
          ),
        )
        .toList();
  }
}

class _InvCounts {
  const _InvCounts({
    required this.lowStock,
    required this.outOfStock,
    required this.total,
  });
  final int lowStock;
  final int outOfStock;
  final int total;
}
