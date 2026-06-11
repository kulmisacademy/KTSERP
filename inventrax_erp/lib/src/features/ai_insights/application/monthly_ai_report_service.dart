import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/ai_config.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/local/db_provider.dart';
import '../../../core/store_context.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/app_database.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../../users/domain/app_permission.dart';
import '../data/business_analytics_aggregator.dart';
import '../data/openai_insights_service.dart';
import '../domain/ai_models.dart';
import 'ai_insights_providers.dart';

final monthlyAiReportServiceProvider = Provider<MonthlyAiReportService>((ref) {
  return MonthlyAiReportService(
    ref,
    ref.watch(appDatabaseProvider),
    ref.watch(businessAnalyticsAggregatorProvider),
    ref.watch(openAiInsightsServiceProvider),
  );
});

/// Generates at most one AI monthly report per store per calendar month.
class MonthlyAiReportService {
  MonthlyAiReportService(this._ref, this._db, this._aggregator, this._ai);

  final Ref _ref;
  final AppDatabase _db;
  final BusinessAnalyticsAggregator _aggregator;
  final OpenAiInsightsService _ai;

  static bool _running = false;

  /// Call after login/sync — runs in background, does not block UI.
  Future<void> runIfNeeded() async {
    if (_running) return;
    if (!StoreContext.isLoggedIn) return;
    if (!StoreContext.can(AppPermission.aiInsightsView)) return;
    if (!AiConfig.isConfigured) return;

    _running = true;
    try {
      await _generateIfNeeded();
    } finally {
      _running = false;
    }
  }

  Future<void> _generateIfNeeded() async {
    final period = DateFormat('yyyy-MM').format(DateTime.now());

    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient;
      if (client != null) {
        try {
          final claimed = await client.rpc(
            'inventrax_try_claim_ai_monthly_report',
            params: {'p_period': period},
          );
          if (claimed != true) return;
        } catch (e) {
          if (kDebugMode) debugPrint('monthly AI claim RPC: $e');
          return;
        }
      }
    }

    final snapshot = await _aggregator.buildSnapshot();
    final locale = _ref.read(appLocaleProvider);
    final l10n = lookupAppLocalizations(locale.flutterLocale);
    final risks = _aggregator.detectRisks(snapshot, l10n: l10n);

    try {
      final response = await _ai.analyze(
        userQuestion: 'Monthly executive report',
        snapshot: snapshot,
        localRisks: risks,
        reportType: 'monthly',
        language: locale.aiLanguageName,
        languageCode: locale.code,
      );

      final title = 'AI Monthly Report — ${DateFormat.yMMMM().format(DateTime.now())}';
      final body = _formatNotificationBody(response);

      await _db.insertAppNotification(
        tenantId: StoreContext.tenantId,
        storeId: StoreContext.storeId,
        type: 'ai_monthly_report',
        title: title,
        body: body,
      );

      if (SupabaseConfig.isConfigured && supabaseClient != null) {
        try {
          await supabaseClient!.from('store_ai_report_periods').update({
            'summary': response.summary,
          }).eq('store_id', StoreContext.storeId).eq('period', period);
        } catch (_) {}
      }

      if (kDebugMode) {
        debugPrint('Monthly AI report notification created for $period');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Monthly AI report failed: $e');
    }
  }

  String _formatNotificationBody(AiInsightResponse response) {
    final recs = response.recommendations.take(2).join(' • ');
    if (recs.isEmpty) return response.summary;
    return '${response.summary}\n\nTop actions: $recs';
  }
}
