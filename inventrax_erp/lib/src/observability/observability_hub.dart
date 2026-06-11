import 'package:flutter/foundation.dart';

/// In-memory operational metrics and event log (lightweight, non-blocking).
class ObservabilityHub {
  ObservabilityHub._();

  static final ObservabilityHub instance = ObservabilityHub._();

  static const maxEvents = 120;

  final List<ObservabilityEvent> _events = [];

  DateTime? lastPullAt;
  DateTime? lastPushAt;
  DateTime? lastSyncSuccessAt;
  String? lastSyncError;

  RealtimeConnectionState realtimeState = RealtimeConnectionState.disconnected;
  String? realtimeDetail;

  SchedulerSnapshot scheduler = const SchedulerSnapshot();

  DateTime? lastAnalyticsRefreshAt;
  String? lastAnalyticsRefreshError;

  bool? networkOnline;
  DateTime? networkCheckedAt;

  /// Fired when [setRealtime] changes state (for Riverpod/UI refresh).
  VoidCallback? onRealtimeChanged;

  void log(
    String category,
    String message, {
    ObservabilityLevel level = ObservabilityLevel.info,
  }) {
    final event = ObservabilityEvent(
      at: DateTime.now(),
      category: category,
      message: message,
      level: level,
    );
    _events.insert(0, event);
    if (_events.length > maxEvents) {
      _events.removeRange(maxEvents, _events.length);
    }
    if (kDebugMode) {
      debugPrint('[obs:$category] $message');
    }
  }

  List<ObservabilityEvent> recentEvents({int limit = 40}) =>
      _events.take(limit).toList(growable: false);

  void recordSyncSuccess({required int pulled, required int pushed}) {
    final now = DateTime.now();
    lastSyncSuccessAt = now;
    lastPullAt = now;
    lastPushAt = now;
    lastSyncError = null;
    log('sync', 'Cycle OK — pulled $pulled, pushed $pushed');
  }

  void recordSyncFailure(Object error) {
    lastSyncError = error.toString();
    log('sync', 'Cycle failed: $lastSyncError', level: ObservabilityLevel.error);
  }

  void recordPull(int pulled) {
    lastPullAt = DateTime.now();
    if (pulled > 0) log('sync', 'Pulled $pulled row(s)');
  }

  void recordPush(int pushed) {
    lastPushAt = DateTime.now();
    if (pushed > 0) log('sync', 'Pushed $pushed row(s)');
  }

  void setRealtime(RealtimeConnectionState state, {String? detail}) {
    if (realtimeState == state && realtimeDetail == detail) return;
    realtimeState = state;
    realtimeDetail = detail;
    log('realtime', detail ?? state.name);
    onRealtimeChanged?.call();
  }

  void setScheduler(SchedulerSnapshot snapshot) {
    scheduler = snapshot;
  }

  void setNetwork(bool online) {
    final changed = networkOnline != online;
    networkOnline = online;
    networkCheckedAt = DateTime.now();
    if (changed) {
      log(
        'network',
        online ? 'Online' : 'Offline — POS continues locally',
        level: online ? ObservabilityLevel.info : ObservabilityLevel.warning,
      );
    }
  }
}

enum ObservabilityLevel { info, warning, error }

enum RealtimeConnectionState {
  connected,
  reconnecting,
  disconnected,
  failed,
}

class ObservabilityEvent {
  const ObservabilityEvent({
    required this.at,
    required this.category,
    required this.message,
    required this.level,
  });

  final DateTime at;
  final String category;
  final String message;
  final ObservabilityLevel level;
}

class SchedulerSnapshot {
  const SchedulerSnapshot({
    this.running = false,
    this.lastTickAt,
    this.lastError,
    this.intervalSeconds = 45,
    this.tickInProgress = false,
  });

  final bool running;
  final DateTime? lastTickAt;
  final String? lastError;
  final int intervalSeconds;
  final bool tickInProgress;

  SchedulerSnapshot copyWith({
    bool? running,
    DateTime? lastTickAt,
    String? lastError,
    int? intervalSeconds,
    bool? tickInProgress,
  }) =>
      SchedulerSnapshot(
        running: running ?? this.running,
        lastTickAt: lastTickAt ?? this.lastTickAt,
        lastError: lastError,
        intervalSeconds: intervalSeconds ?? this.intervalSeconds,
        tickInProgress: tickInProgress ?? this.tickInProgress,
      );
}
