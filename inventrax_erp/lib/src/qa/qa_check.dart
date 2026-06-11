/// Result of a single automated QA / integrity check.
class QaCheckResult {
  const QaCheckResult({
    required this.id,
    required this.title,
    required this.category,
    required this.passed,
    required this.message,
    this.durationMs,
    this.severity = QaSeverity.info,
  });

  final String id;
  final String title;
  final String category;
  final bool passed;
  final String message;
  final int? durationMs;
  final QaSeverity severity;
}

enum QaSeverity { info, warning, critical }

class QaRunReport {
  const QaRunReport({
    required this.checks,
    required this.startedAt,
    required this.finishedAt,
  });

  final List<QaCheckResult> checks;
  final DateTime startedAt;
  final DateTime finishedAt;

  int get passCount => checks.where((c) => c.passed).length;
  int get failCount => checks.where((c) => !c.passed).length;
  bool get allPassed => failCount == 0;

  Duration get duration => finishedAt.difference(startedAt);
}
