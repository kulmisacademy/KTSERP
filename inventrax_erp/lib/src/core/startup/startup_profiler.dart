import 'package:flutter/foundation.dart';

/// Lightweight startup timing profiler.
///
/// Logs are printed via [debugPrint], which is visible in the browser console
/// in **release** web builds too — so production startup can be measured live.
///
/// Read the timeline in the console by filtering for `[startup]`.
class StartupProfiler {
  StartupProfiler._();

  static final Stopwatch _sw = Stopwatch()..start();

  /// Ordered list of (label, elapsedMsSinceStart) for in-app inspection.
  static final List<MapEntry<String, int>> marks = <MapEntry<String, int>>[];

  /// Set false to silence logs (timeline is still recorded in [marks]).
  static bool logging = true;

  /// Records an instantaneous milestone.
  static void mark(String label) {
    final ms = _sw.elapsedMilliseconds;
    marks.add(MapEntry(label, ms));
    if (logging) {
      debugPrint('[startup] $label @ ${ms}ms');
    }
  }

  /// Times an async task and logs how long it took.
  static Future<T> track<T>(String label, Future<T> Function() task) async {
    final start = _sw.elapsedMilliseconds;
    try {
      return await task();
    } finally {
      final took = _sw.elapsedMilliseconds - start;
      marks.add(MapEntry('$label (took ${took}ms)', _sw.elapsedMilliseconds));
      if (logging) {
        debugPrint(
          '[startup] $label took ${took}ms (@${_sw.elapsedMilliseconds}ms)',
        );
      }
    }
  }
}
