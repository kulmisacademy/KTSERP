// AI Business Intelligence models (aggregates + parsed responses).

class AiMetricChip {
  const AiMetricChip({required this.label, required this.value});
  final String label;
  final String value;

  factory AiMetricChip.fromJson(Map<String, dynamic> j) => AiMetricChip(
        label: j['label'] as String? ?? '',
        value: j['value'] as String? ?? '',
      );
}

enum AiChartKind {
  revenueTrend,
  profitTrend,
  expenseComparison,
  productPerformance,
  inventory,
  unknown,
}

class AiChartHint {
  const AiChartHint({
    required this.kind,
    required this.title,
    this.subtitle,
  });

  final AiChartKind kind;
  final String title;
  final String? subtitle;

  static AiChartKind parseKind(String? raw) {
    final k = raw?.toLowerCase().replaceAll('_', '') ?? '';
    switch (raw?.toLowerCase()) {
      case 'revenuetrend':
      case 'revenue_trend':
      case 'revenue':
        return AiChartKind.revenueTrend;
      case 'profittrend':
      case 'profit_trend':
      case 'profit':
        return AiChartKind.profitTrend;
      case 'expensecomparison':
      case 'expense_comparison':
      case 'expenses':
        return AiChartKind.expenseComparison;
      case 'productperformance':
      case 'product_performance':
      case 'products':
        return AiChartKind.productPerformance;
      case 'inventory':
        return AiChartKind.inventory;
      default:
        if (k.contains('revenue')) return AiChartKind.revenueTrend;
        if (k.contains('profit')) return AiChartKind.profitTrend;
        if (k.contains('expense')) return AiChartKind.expenseComparison;
        if (k.contains('product')) return AiChartKind.productPerformance;
        return AiChartKind.unknown;
    }
  }

  factory AiChartHint.fromJson(Map<String, dynamic> j) => AiChartHint(
        kind: parseKind(j['type'] as String?),
        title: j['title'] as String? ?? 'Chart',
        subtitle: j['subtitle'] as String?,
      );
}

class AiInsightResponse {
  const AiInsightResponse({
    required this.summary,
    this.metrics = const [],
    this.recommendations = const [],
    this.warnings = const [],
    this.opportunities = const [],
    this.chartHints = const [],
    this.rawText,
  });

  final String summary;
  final List<AiMetricChip> metrics;
  final List<String> recommendations;
  final List<String> warnings;
  final List<String> opportunities;
  final List<AiChartHint> chartHints;
  final String? rawText;

  factory AiInsightResponse.fromJson(Map<String, dynamic> j) {
    List<String> strings(dynamic raw) {
      if (raw is! List) return [];
      return raw.map((e) => e.toString()).toList();
    }

    return AiInsightResponse(
      summary: j['summary'] as String? ?? '',
      metrics: (j['metrics'] as List?)
              ?.map((e) => AiMetricChip.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      recommendations: strings(j['recommendations']),
      warnings: strings(j['warnings']),
      opportunities: strings(j['opportunities']),
      chartHints: (j['charts'] as List?)
              ?.map((e) => AiChartHint.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  factory AiInsightResponse.fallback(String text) => AiInsightResponse(
        summary: text,
        rawText: text,
      );
}

class AiBusinessRisk {
  const AiBusinessRisk({
    required this.severity,
    required this.title,
    required this.message,
  });

  final String severity; // high | medium | low
  final String title;
  final String message;
}

class AiTrendPoint {
  const AiTrendPoint({required this.label, required this.cents});
  final String label;
  final int cents;
}

class AiProductRank {
  const AiProductRank({
    required this.name,
    required this.quantity,
    this.revenueCents = 0,
  });

  final String name;
  final int quantity;
  final int revenueCents;
}

class AiDebtorRank {
  const AiDebtorRank({required this.name, required this.remainingCents});
  final String name;
  final int remainingCents;
}

class AiExpenseCategory {
  const AiExpenseCategory({required this.category, required this.cents});
  final String category;
  final int cents;
}

/// Precomputed store analytics — safe to send to OpenAI (summarized only).
class AiBusinessSnapshot {
  const AiBusinessSnapshot({
    required this.storeId,
    required this.storeName,
    required this.currency,
    required this.generatedAt,
    required this.todaySalesCents,
    required this.monthSalesCents,
    required this.prevMonthSalesCents,
    required this.last7SalesCents,
    required this.prev7SalesCents,
    required this.monthExpensesCents,
    required this.monthCogsCents,
    required this.monthProfitCents,
    required this.monthPurchasesCents,
    required this.customerReceivablesCents,
    required this.supplierPayablesCents,
    required this.overdueDebtCount,
    required this.productCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.salesTrend7d,
    required this.topProducts,
    required this.lowStockProducts,
    required this.slowMovingProducts,
    required this.topDebtors,
    required this.expensesByCategory,
  });

  final String storeId;
  final String storeName;
  final String currency;
  final DateTime generatedAt;
  final int todaySalesCents;
  final int monthSalesCents;
  final int prevMonthSalesCents;
  final int last7SalesCents;
  final int prev7SalesCents;
  final int monthExpensesCents;
  final int monthCogsCents;
  final int monthProfitCents;
  final int monthPurchasesCents;
  final int customerReceivablesCents;
  final int supplierPayablesCents;
  final int overdueDebtCount;
  final int productCount;
  final int lowStockCount;
  final int outOfStockCount;
  final List<AiTrendPoint> salesTrend7d;
  final List<AiProductRank> topProducts;
  final List<AiProductRank> lowStockProducts;
  final List<AiProductRank> slowMovingProducts;
  final List<AiDebtorRank> topDebtors;
  final List<AiExpenseCategory> expensesByCategory;

  double? get salesWeekOverWeekPct {
    if (prev7SalesCents <= 0) return null;
    return ((last7SalesCents - prev7SalesCents) / prev7SalesCents) * 100;
  }

  double get expenseRatioPct =>
      monthSalesCents > 0 ? (monthExpensesCents / monthSalesCents) * 100 : 0;

  double get profitMarginPct =>
      monthSalesCents > 0 ? (monthProfitCents / monthSalesCents) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'currency': currency,
        'generatedAt': generatedAt.toIso8601String(),
        'todaySalesCents': todaySalesCents,
        'monthSalesCents': monthSalesCents,
        'prevMonthSalesCents': prevMonthSalesCents,
        'last7SalesCents': last7SalesCents,
        'prev7SalesCents': prev7SalesCents,
        'salesWeekOverWeekPct': salesWeekOverWeekPct,
        'monthExpensesCents': monthExpensesCents,
        'monthCogsCents': monthCogsCents,
        'monthProfitCents': monthProfitCents,
        'monthPurchasesCents': monthPurchasesCents,
        'expenseRatioPct': expenseRatioPct,
        'profitMarginPct': profitMarginPct,
        'customerReceivablesCents': customerReceivablesCents,
        'supplierPayablesCents': supplierPayablesCents,
        'overdueDebtCount': overdueDebtCount,
        'productCount': productCount,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'salesTrend7d': salesTrend7d
            .map((p) => {'label': p.label, 'cents': p.cents})
            .toList(),
        'topProducts': topProducts
            .map((p) => {
                  'name': p.name,
                  'quantity': p.quantity,
                  'revenueCents': p.revenueCents,
                })
            .toList(),
        'lowStockProducts':
            lowStockProducts.map((p) => {'name': p.name, 'quantity': p.quantity}).toList(),
        'slowMovingProducts':
            slowMovingProducts.map((p) => {'name': p.name, 'quantity': p.quantity}).toList(),
        'topDebtors': topDebtors
            .map((d) => {'name': d.name, 'remainingCents': d.remainingCents})
            .toList(),
        'expensesByCategory':
            expensesByCategory.map((e) => {'category': e.category, 'cents': e.cents}).toList(),
      };
}
