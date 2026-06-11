import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ai_models.dart';

/// Caches expensive AI responses per store + question fingerprint.
class AiInsightsCache {
  static const _prefix = 'ai_insights_v1_';
  static const _ttlHours = 6;

  Future<AiInsightResponse?> get({
    required String storeId,
    required String questionKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix${storeId}_$questionKey');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.parse(map['cachedAt'] as String);
      if (DateTime.now().difference(at).inHours > _ttlHours) return null;
      return AiInsightResponse.fromJson(
        Map<String, dynamic>.from(map['response'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> put({
    required String storeId,
    required String questionKey,
    required AiInsightResponse response,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${storeId}_$questionKey',
      jsonEncode({
        'cachedAt': DateTime.now().toIso8601String(),
        'response': {
          'summary': response.summary,
          'metrics': response.metrics
              .map((m) => {'label': m.label, 'value': m.value})
              .toList(),
          'recommendations': response.recommendations,
          'warnings': response.warnings,
          'opportunities': response.opportunities,
          'charts': response.chartHints.map((c) {
            String type = switch (c.kind) {
              AiChartKind.revenueTrend => 'revenue_trend',
              AiChartKind.profitTrend => 'profit_trend',
              AiChartKind.expenseComparison => 'expense_comparison',
              AiChartKind.productPerformance => 'product_performance',
              AiChartKind.inventory => 'inventory',
              AiChartKind.unknown => 'revenue_trend',
            };
            return {
              'type': type,
              'title': c.title,
              'subtitle': c.subtitle,
            };
          }).toList(),
        },
      }),
    );
  }

  static String questionKey(String question) {
    final q = question.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return q.length > 80 ? q.substring(0, 80) : q;
  }

  /// Removes AI cache entries from other stores (login / store switch).
  Future<void> clearExceptStore(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = '$_prefix';
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(prefix)) continue;
      if (storeId.isEmpty || !key.startsWith('$prefix${storeId}_')) {
        await prefs.remove(key);
      }
    }
  }
}
