import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/ai_config.dart';
import '../../../core/supabase_config.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../domain/ai_models.dart';
import '../domain/ai_response_sanitizer.dart';

class OpenAiInsightsService {
  const OpenAiInsightsService();

  static const _systemPrompt = '''
You are InventraX AI — an expert retail ERP business analyst for store owners.
You receive ONLY pre-aggregated JSON metrics (never raw transactions).
Respond with valid JSON only (no markdown fences) using this schema:
{
  "summary": "2-4 sentences, clear executive summary",
  "metrics": [{"label": "string", "value": "string"}],
  "recommendations": ["actionable bullet strings"],
  "warnings": ["risk bullet strings"],
  "opportunities": ["growth bullet strings"],
  "charts": [{"type": "revenue_trend|profit_trend|expense_comparison|product_performance|inventory", "title": "string", "subtitle": "optional"}]
}
Rules:
- Use the store currency when mentioning money (convert cents to major units).
- Be specific; cite numbers from the payload.
- Max 5 recommendations, 4 warnings, 3 opportunities, 6 metrics.
- Suggest chart types that match available data in the payload.
- If data is sparse, say so honestly.
- Answer ONLY the current question; do not repeat prior_turns summaries verbatim.
- Each recommendation, warning, and opportunity must be unique (no duplicate bullets).
- Do not restate the same fact in summary and bullet lists.
''';

  Future<AiInsightResponse> analyze({
    required String userQuestion,
    required AiBusinessSnapshot snapshot,
    List<AiBusinessRisk> localRisks = const [],
    String reportType = 'chat',
    String language = 'English',
    String languageCode = 'en',
    List<Map<String, String>> priorTurns = const [],
  }) async {
    if (!AiConfig.isConfigured) {
      return _offlineInsight(snapshot, localRisks, userQuestion);
    }

    final risksText = localRisks
        .map((r) => '[${r.severity}] ${r.title}: ${r.message}')
        .join('\n');

    if (AiConfig.useEdgeProxy) {
      return _analyzeViaEdge(
        userQuestion: userQuestion,
        snapshot: snapshot,
        risksText: risksText,
        reportType: reportType,
        language: language,
        languageCode: languageCode,
        priorTurns: priorTurns,
      );
    }

    return _analyzeDirect(
      userQuestion: userQuestion,
      snapshot: snapshot,
      risksText: risksText,
      language: language,
      languageCode: languageCode,
      priorTurns: priorTurns,
    );
  }

  Future<AiInsightResponse> _analyzeViaEdge({
    required String userQuestion,
    required AiBusinessSnapshot snapshot,
    required String risksText,
    required String reportType,
    required String language,
    required String languageCode,
    List<Map<String, String>> priorTurns = const [],
  }) async {
    final client = supabaseClient;
    if (client == null) {
      throw OpenAiInsightsException('Supabase not initialized');
    }

    final res = await client.functions.invoke(
      'ai-insights',
      body: {
        'question': userQuestion,
        'analytics': snapshot.toJson(),
        'detected_risks': risksText,
        'report_type': reportType,
        'model': AiConfig.model,
        'language': language,
        'language_code': languageCode,
        'prior_turns': priorTurns,
      },
    );

    if (res.status != 200) {
      final err = res.data is Map ? (res.data as Map)['error'] : res.data;
      throw OpenAiInsightsException(
        err?.toString() ?? 'AI proxy error (${res.status})',
      );
    }

    final data = res.data;
    Map<String, dynamic>? parsed;
    if (data is Map) {
      final inner = data['response'];
      if (inner is Map) {
        parsed = Map<String, dynamic>.from(inner);
      } else if (data['summary'] != null) {
        parsed = Map<String, dynamic>.from(data);
      }
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        parsed = decoded['response'] is Map
            ? Map<String, dynamic>.from(decoded['response'] as Map)
            : decoded;
      } catch (_) {}
    }

    if (parsed == null) {
      throw OpenAiInsightsException('Invalid AI proxy response');
    }
    return AiResponseSanitizer.sanitize(AiInsightResponse.fromJson(parsed));
  }

  /// Streams raw JSON tokens from the edge proxy (SSE). Falls back to [analyze] on error.
  Stream<String> analyzeStream({
    required String userQuestion,
    required AiBusinessSnapshot snapshot,
    List<AiBusinessRisk> localRisks = const [],
    String reportType = 'chat',
    String language = 'English',
    String languageCode = 'en',
    List<Map<String, String>> priorTurns = const [],
  }) async* {
    if (!AiConfig.useEdgeProxy) {
      final result = await analyze(
        userQuestion: userQuestion,
        snapshot: snapshot,
        localRisks: localRisks,
        reportType: reportType,
        language: language,
        languageCode: languageCode,
        priorTurns: priorTurns,
      );
      yield result.summary;
      return;
    }

    final client = supabaseClient;
    final session = client?.auth.currentSession;
    if (client == null || session == null) {
      throw OpenAiInsightsException('Supabase not initialized');
    }

    final risksText = localRisks
        .map((r) => '[${r.severity}] ${r.title}: ${r.message}')
        .join('\n');

    final request = http.Request(
      'POST',
      Uri.parse('${SupabaseConfig.url}/functions/v1/ai-insights'),
    );
    request.headers['Authorization'] = 'Bearer ${session.accessToken}';
    request.headers['apikey'] = SupabaseConfig.anonKey;
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'question': userQuestion,
      'analytics': snapshot.toJson(),
      'detected_risks': risksText,
      'report_type': reportType,
      'model': AiConfig.model,
      'language': language,
      'language_code': languageCode,
      'prior_turns': priorTurns,
      'stream': true,
    });

    final response = await request.send().timeout(
          Duration(milliseconds: AiConfig.timeoutMs),
        );
    if (response.statusCode != 200) {
      final err = await response.stream.bytesToString();
      throw OpenAiInsightsException(err.isNotEmpty ? err : 'AI stream error');
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') break;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final choices = decoded['choices'] as List?;
        if (choices == null || choices.isEmpty) continue;
        final delta =
            (choices.first as Map)['delta']?['content'] as String?;
        if (delta != null && delta.isNotEmpty) yield delta;
      } catch (_) {}
    }
  }

  static String streamingSummaryPreview(String accumulated) {
    final match = RegExp(
      r'"summary"\s*:\s*"((?:[^"\\]|\\.)*)',
    ).firstMatch(accumulated);
    if (match != null) {
      return match.group(1)!.replaceAll(r'\n', '\n').replaceAll(r'\"', '"');
    }
    return accumulated.length > 280
        ? '${accumulated.substring(0, 280)}…'
        : accumulated;
  }

  static AiInsightResponse? parseStreamedJson(String accumulated) {
    try {
      final parsed = jsonDecode(accumulated) as Map<String, dynamic>;
      return AiResponseSanitizer.sanitize(AiInsightResponse.fromJson(parsed));
    } catch (_) {
      final summary = streamingSummaryPreview(accumulated);
      if (summary.isEmpty) return null;
      return AiResponseSanitizer.sanitize(AiInsightResponse.fallback(summary));
    }
  }

  Future<AiInsightResponse> _analyzeDirect({
    required String userQuestion,
    required AiBusinessSnapshot snapshot,
    required String risksText,
    required String language,
    required String languageCode,
    List<Map<String, String>> priorTurns = const [],
  }) async {
    final userPayload = jsonEncode({
      'question': userQuestion,
      'analytics': snapshot.toJson(),
      'detectedRisks': risksText,
      'language': language,
      'language_code': languageCode,
      'prior_turns': priorTurns,
      'instruction':
          'Respond entirely in $language. Answer the current question only; do not repeat prior_turns.',
    });

    final body = jsonEncode({
      'model': AiConfig.model,
      'temperature': 0.35,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': 'Analyze this store data and answer the question:\n$userPayload',
        },
      ],
    });

    final res = await http
        .post(
          Uri.parse('${AiConfig.apiBase}/chat/completions'),
          headers: {
            'Authorization': 'Bearer ${AiConfig.apiKey}',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(Duration(milliseconds: AiConfig.timeoutMs));

    if (res.statusCode != 200) {
      if (kDebugMode) debugPrint('OpenAI error ${res.statusCode}: ${res.body}');
      throw OpenAiInsightsException(
        _friendlyError(res.statusCode, res.body),
      );
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw OpenAiInsightsException('Empty AI response');
    }
    final content =
        (choices.first as Map)['message']?['content'] as String? ?? '';
    try {
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return AiResponseSanitizer.sanitize(AiInsightResponse.fromJson(parsed));
    } catch (e) {
      return AiResponseSanitizer.sanitize(AiInsightResponse.fallback(content));
    }
  }

  AiInsightResponse _offlineInsight(
    AiBusinessSnapshot s,
    List<AiBusinessRisk> risks,
    String question,
  ) {
    final currency = s.currency;
    final mrr = (s.monthSalesCents / 100).toStringAsFixed(2);
    final profit = (s.monthProfitCents / 100).toStringAsFixed(2);
    final summary = 'Offline analysis for ${s.storeName}: month sales $mrr $currency, '
        'profit $profit $currency. '
        '${risks.isNotEmpty ? "Detected ${risks.length} risk(s)." : "No critical risks detected."} '
        'Configure Supabase Edge Function secret OPENAI_API_KEY for full AI.';

    return AiInsightResponse(
      summary: summary,
      metrics: [
        AiMetricChip(label: 'Today sales', value: '${(s.todaySalesCents / 100).toStringAsFixed(2)} $currency'),
        AiMetricChip(label: 'Month sales', value: '$mrr $currency'),
        AiMetricChip(label: 'Month profit', value: '$profit $currency'),
        AiMetricChip(label: 'Customer debt', value: '${(s.customerReceivablesCents / 100).toStringAsFixed(2)} $currency'),
      ],
      recommendations: [
        if (s.lowStockCount > 0) 'Reorder low-stock items before you lose sales.',
        if (s.topProducts.isNotEmpty) 'Keep extra stock for top seller: ${s.topProducts.first.name}.',
        if (s.overdueDebtCount > 0) 'Follow up on overdue customer payments.',
      ],
      warnings: risks.map((r) => r.message).toList(),
      chartHints: const [
        AiChartHint(kind: AiChartKind.revenueTrend, title: '7-day sales trend'),
        AiChartHint(kind: AiChartKind.expenseComparison, title: 'Expenses by category'),
      ],
      rawText: 'Question: $question',
    );
  }

  String _friendlyError(int code, String body) {
    if (code == 401) return 'Invalid OpenAI API key';
    if (code == 429) return 'OpenAI rate limit — wait a moment and try again';
    if (body.contains('insufficient_quota')) {
      return 'OpenAI quota exceeded. Check billing at platform.openai.com';
    }
    return 'AI service error ($code)';
  }
}

class OpenAiInsightsException implements Exception {
  OpenAiInsightsException(this.message);
  final String message;
  @override
  String toString() => message;
}
