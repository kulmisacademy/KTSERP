import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/store_context.dart';
import '../core/supabase_config.dart';
import '../data/local/db_provider.dart';
import '../observability/observability_hub.dart';
import 'sync_service.dart';
import 'supabase_bootstrap.dart';

/// Periodic sync scheduler (30–60s cadence, backoff on failure).
class SyncScheduler extends Notifier<void> {
  Timer? _timer;
  Duration _interval = const Duration(seconds: 45);
  bool _tickRunning = false;

  @override
  void build() {
    ref.watch(appDatabaseProvider);

    if (!SupabaseConfig.isConfigured || supabaseClient == null) return;
    if (!StoreContext.isLoggedIn) return;

    ObservabilityHub.instance.setScheduler(
      SchedulerSnapshot(running: true, intervalSeconds: _interval.inSeconds),
    );
    _schedule();

    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
      ObservabilityHub.instance.setScheduler(const SchedulerSnapshot());
    });
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(_interval, () {
      Future.microtask(_tick);
    });
  }

  Future<void> _tick() async {
    if (_tickRunning) return;
    if (!SupabaseConfig.isConfigured || supabaseClient == null) return;
    if (!StoreContext.isLoggedIn) return;

    _tickRunning = true;
    final hub = ObservabilityHub.instance;
    hub.setScheduler(
      hub.scheduler.copyWith(
        tickInProgress: true,
        lastTickAt: DateTime.now(),
        intervalSeconds: _interval.inSeconds,
      ),
    );

    try {
      await ref.read(syncWorkerProvider.notifier).fullSync();
      _interval = const Duration(seconds: 45);
      hub.setScheduler(
        hub.scheduler.copyWith(
          tickInProgress: false,
          lastError: null,
          intervalSeconds: _interval.inSeconds,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncScheduler tick failed: $e');
      final nextSeconds = (_interval.inSeconds * 2).clamp(30, 300);
      _interval = Duration(seconds: nextSeconds);
      hub.setScheduler(
        hub.scheduler.copyWith(
          tickInProgress: false,
          lastError: e.toString(),
          intervalSeconds: _interval.inSeconds,
        ),
      );
    } finally {
      _tickRunning = false;
      _schedule();
    }
  }
}

final syncSchedulerProvider = NotifierProvider<SyncScheduler, void>(
  SyncScheduler.new,
);
