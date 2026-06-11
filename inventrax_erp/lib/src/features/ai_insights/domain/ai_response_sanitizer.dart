import 'ai_models.dart';

/// Strips duplicate bullets and overlap with the executive summary.
class AiResponseSanitizer {
  const AiResponseSanitizer._();

  static AiInsightResponse sanitize(AiInsightResponse raw) {
    final summary = raw.summary.trim();
    final summaryNorm = _normalize(summary);

    return AiInsightResponse(
      summary: summary,
      metrics: _dedupeMetrics(raw.metrics),
      recommendations: _dedupeStrings(
        raw.recommendations,
        summaryNorm: summaryNorm,
      ),
      warnings: _dedupeStrings(raw.warnings, summaryNorm: summaryNorm),
      opportunities: _dedupeStrings(raw.opportunities, summaryNorm: summaryNorm),
      chartHints: raw.chartHints,
      rawText: raw.rawText,
    );
  }

  static List<AiMetricChip> _dedupeMetrics(List<AiMetricChip> items) {
    final seen = <String>{};
    final out = <AiMetricChip>[];
    for (final m in items) {
      final key = '${m.label}|${m.value}'.toLowerCase();
      if (seen.add(key)) out.add(m);
    }
    return out;
  }

  static List<String> _dedupeStrings(
    List<String> items, {
    required String summaryNorm,
  }) {
    final seen = <String>{};
    final out = <String>[];
    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      final norm = _normalize(trimmed);
      if (seen.contains(norm)) continue;
      if (summaryNorm.isNotEmpty && _isContainedInSummary(norm, summaryNorm)) {
        continue;
      }
      var duplicate = false;
      for (final prior in seen) {
        if (_isNearDuplicate(norm, prior)) {
          duplicate = true;
          break;
        }
      }
      if (duplicate) continue;
      seen.add(norm);
      out.add(trimmed);
    }
    return out;
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool _isContainedInSummary(String norm, String summaryNorm) {
    if (norm.length < 12) return false;
    return summaryNorm.contains(norm);
  }

  static bool _isNearDuplicate(String a, String b) {
    if (a == b) return true;
    if (a.length >= 24 && b.contains(a)) return true;
    if (b.length >= 24 && a.contains(b)) return true;
    return false;
  }
}
