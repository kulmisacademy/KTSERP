import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/ai_config.dart';
import '../../../core/l10n/app_locale.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/ai_insights_cache.dart';
import '../data/business_analytics_aggregator.dart';
import '../data/openai_insights_service.dart';
import '../domain/ai_models.dart';
import '../domain/ai_response_sanitizer.dart';

final businessAnalyticsAggregatorProvider = Provider<BusinessAnalyticsAggregator>((ref) {
  return BusinessAnalyticsAggregator(ref.watch(appDatabaseProvider));
});

final aiBusinessSnapshotProvider = FutureProvider<AiBusinessSnapshot>((ref) async {
  ref.keepAlive();
  final settings = ref.watch(storeSettingsProvider.select((a) => a.value));
  final agg = ref.watch(businessAnalyticsAggregatorProvider);
  return agg.buildSnapshot(
    storeName: settings?.storeName,
    currency: settings?.currencyCode,
  );
});

final aiLocalRisksProvider = Provider.autoDispose<List<AiBusinessRisk>>((ref) {
  final snap = ref.watch(aiBusinessSnapshotProvider).value;
  if (snap == null) return [];
  final locale = ref.watch(appLocaleProvider);
  final l10n = lookupAppLocalizations(locale.flutterLocale);
  return ref.watch(businessAnalyticsAggregatorProvider).detectRisks(
        snap,
        l10n: l10n,
      );
});

final openAiInsightsServiceProvider = Provider<OpenAiInsightsService>(
  (ref) => const OpenAiInsightsService(),
);

final aiInsightsCacheProvider = Provider<AiInsightsCache>(
  (ref) => AiInsightsCache(),
);

class AiChatMessage {
  const AiChatMessage({
    required this.role,
    required this.text,
    this.response,
    this.isLoading = false,
    this.error,
    this.id,
  });

  final String role; // user | assistant
  final String text;
  final AiInsightResponse? response;
  final bool isLoading;
  final String? error;
  final int? id;

  static int _idSeq = 0;
  static int nextId() => ++_idSeq;
}

List<Map<String, String>> _priorTurnsJson(List<AiChatMessage> messages) {
  const maxTurns = 3;
  final turns = <Map<String, String>>[];
  String? pendingQuestion;

  for (final m in messages) {
    if (m.isLoading || m.error != null) continue;
    if (m.role == 'user') {
      pendingQuestion = m.text.trim();
    } else if (m.role == 'assistant' && pendingQuestion != null) {
      final summary = (m.response?.summary ?? m.text).trim();
      if (summary.isNotEmpty) {
        turns.add({'question': pendingQuestion, 'summary': summary});
      }
      pendingQuestion = null;
    }
  }

  if (turns.length <= maxTurns) return turns;
  return turns.sublist(turns.length - maxTurns);
}

String _cacheKey(String question, List<AiChatMessage> history) {
  final base = AiInsightsCache.questionKey(question);
  final priorCount =
      history.where((m) => m.role == 'assistant' && m.response != null && !m.isLoading).length;
  return priorCount == 0 ? base : '${base}_t$priorCount';
}

class AiInsightsChatController extends Notifier<List<AiChatMessage>> {
  DateTime? _lastRequestAt;
  bool _busy = false;

  @override
  List<AiChatMessage> build() => [];

  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || _busy) return;

    final now = DateTime.now();
    if (_lastRequestAt != null &&
        now.difference(_lastRequestAt!).inMilliseconds < AiConfig.minRequestIntervalMs) {
      final locale = ref.read(appLocaleProvider);
      state = [
        ...state,
        AiChatMessage(
          role: 'assistant',
          text: '',
          error: _rateLimitMessage(locale),
          id: AiChatMessage.nextId(),
        ),
      ];
      return;
    }

    final priorTurns = _priorTurnsJson(state);
    final loadingId = AiChatMessage.nextId();

    state = [
      ...state,
      AiChatMessage(role: 'user', text: q, id: AiChatMessage.nextId()),
      AiChatMessage(role: 'assistant', text: '', isLoading: true, id: loadingId),
    ];

    _busy = true;
    try {
      final snapshot = await ref.read(aiBusinessSnapshotProvider.future);
      final locale = ref.read(appLocaleProvider);
      final l10n = lookupAppLocalizations(locale.flutterLocale);
      final risks = ref.read(businessAnalyticsAggregatorProvider).detectRisks(
            snapshot,
            l10n: l10n,
          );
      final cache = ref.read(aiInsightsCacheProvider);
      final key = _cacheKey(q, state);

      AiInsightResponse? response = await cache.get(
        storeId: snapshot.storeId,
        questionKey: key,
      );

      if (response == null) {
        _lastRequestAt = now;
        final service = ref.read(openAiInsightsServiceProvider);
        var accumulated = '';
        try {
          await for (final chunk in service.analyzeStream(
            userQuestion: q,
            snapshot: snapshot,
            localRisks: risks,
            language: locale.aiLanguageName,
            languageCode: locale.code,
            priorTurns: priorTurns,
          )) {
            accumulated += chunk;
            final preview =
                OpenAiInsightsService.streamingSummaryPreview(accumulated);
            final partial = [...state];
            final pIdx = partial.indexWhere((m) => m.id == loadingId);
            if (pIdx >= 0) {
              partial[pIdx] = AiChatMessage(
                role: 'assistant',
                text: preview,
                isLoading: true,
                id: loadingId,
              );
              state = partial;
            }
          }
          response = OpenAiInsightsService.parseStreamedJson(accumulated) ??
              await service.analyze(
                userQuestion: q,
                snapshot: snapshot,
                localRisks: risks,
                language: locale.aiLanguageName,
                languageCode: locale.code,
                priorTurns: priorTurns,
              );
        } catch (_) {
          response = await service.analyze(
            userQuestion: q,
            snapshot: snapshot,
            localRisks: risks,
            language: locale.aiLanguageName,
            languageCode: locale.code,
            priorTurns: priorTurns,
          );
        }
        response = AiResponseSanitizer.sanitize(response);
        await cache.put(
          storeId: snapshot.storeId,
          questionKey: key,
          response: response,
        );
      } else {
        response = AiResponseSanitizer.sanitize(response);
      }

      final updated = [...state];
      final idx = updated.indexWhere((m) => m.id == loadingId);
      if (idx < 0) return;
      updated[idx] = AiChatMessage(
        role: 'assistant',
        text: response.summary,
        response: response,
        id: loadingId,
      );
      state = updated;
    } catch (e) {
      final updated = [...state];
      final idx = updated.indexWhere((m) => m.isLoading);
      if (idx < 0) return;
      updated[idx] = AiChatMessage(
        role: 'assistant',
        text: '',
        error: e.toString(),
        id: updated[idx].id,
      );
      state = updated;
    } finally {
      _busy = false;
    }
  }

  void clear() => state = [];
}

String _rateLimitMessage(AppLocale locale) => switch (locale) {
      AppLocale.somali =>
        'Fadlan sug dhowr ilbiriqsi inta u dhaxaysa codsiyada AI.',
      AppLocale.arabic =>
        'يرجى الانتظار بضع ثوانٍ بين طلبات الذكاء الاصطناعي.',
      AppLocale.english =>
        'Please wait a few seconds between AI requests.',
    };

final aiInsightsChatProvider =
    NotifierProvider<AiInsightsChatController, List<AiChatMessage>>(
  AiInsightsChatController.new,
);
