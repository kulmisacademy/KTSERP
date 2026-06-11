/// Safe parsing for cloud / SQLite datetime strings (web-safe).
abstract final class SafeDateTime {
  /// Normalizes ISO-like strings missing a timezone suffix for [DateTime.tryParse].
  static String normalize(String value) {
    var s = value.trim();
    if (s.isEmpty) return s;

    // SQLite / legacy: "2026-06-01 18:23:42"
    if (s.contains(' ') && !s.contains('T')) {
      s = s.replaceFirst(' ', 'T');
    }

    final hasTimezone = s.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(s) ||
        RegExp(r'[+-]\d{4}$').hasMatch(s);
    if (!hasTimezone) {
      s = '${s}Z';
    }
    return s;
  }

  /// Parses timestamps from Supabase, sync metadata, or legacy TEXT columns.
  static DateTime? tryParse(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is int) {
      // Drift SQLite: seconds or milliseconds since epoch.
      if (value > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is num) {
      final n = value.toInt();
      if (n > 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
    }
    if (value is String) {
      final raw = value.trim();
      if (raw.isEmpty) return null;
      return DateTime.tryParse(normalize(raw))?.toUtc() ??
          DateTime.tryParse(raw)?.toUtc();
    }
    return null;
  }
}
