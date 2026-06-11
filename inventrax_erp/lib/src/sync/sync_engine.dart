import 'package:flutter/foundation.dart';

import '../core/supabase_config.dart';
import '../data/local/app_database.dart';
import '../observability/monitoring_bootstrap.dart';
import '../observability/observability_hub.dart';
import 'sync_pull_service.dart';
import 'sync_push_service.dart';
import 'supabase_bootstrap.dart';

/// Orchestrates bidirectional sync: pull cloud → local, then push local → cloud.
class SyncEngine {
  SyncEngine(this._db);

  final AppDatabase _db;
  bool _running = false;

  /// Full sync cycle: hydrate from cloud, then upload pending queue.
  Future<SyncEngineResult> fullSync({bool forceFullPull = false}) async {
    if (!SupabaseConfig.isConfigured || supabaseClient == null) {
      return SyncEngineResult.offline();
    }
    if (_running) {
      return SyncEngineResult.busy();
    }

    _running = true;
    try {
      final pullService = SyncPullService(_db);
      final pullResult = forceFullPull
          ? await pullService.pullAll()
          : await pullService.pullIncremental();

      final pushService = SyncPushService(_db);
      await pushService.pushBootstrapAccountingIfNeeded();

      var pushed = 0;
      for (var round = 0; round < 10; round++) {
        final batch = await pushService.pushPending();
        pushed += batch;
        if (batch == 0) break;
      }

      final hub = ObservabilityHub.instance;
      hub.recordPull(pullResult.pulled);
      hub.recordPush(pushed);
      if (pullResult.ok) {
        hub.recordSyncSuccess(pulled: pullResult.pulled, pushed: pushed);
      } else {
        hub.recordSyncFailure(pullResult.message ?? 'Pull failed');
      }

      if (kDebugMode) {
        debugPrint(
          'SyncEngine: pulled=${pullResult.pulled}, pushed=$pushed',
        );
      }

      return SyncEngineResult(
        pulled: pullResult.pulled,
        pushed: pushed,
        pullOk: pullResult.ok,
      );
    } catch (e, st) {
      ObservabilityHub.instance.recordSyncFailure(e);
      MonitoringService.captureException(e, stackTrace: st, hint: 'sync_failure');
      if (kDebugMode) debugPrint('SyncEngine error: $e\n$st');
      rethrow;
    } finally {
      _running = false;
    }
  }

  Future<int> pushOnly() => SyncPushService(_db).pushPending();
}

class SyncEngineResult {
  const SyncEngineResult({
    required this.pulled,
    required this.pushed,
    required this.pullOk,
  });

  final int pulled;
  final int pushed;
  final bool pullOk;

  factory SyncEngineResult.offline() =>
      const SyncEngineResult(pulled: 0, pushed: 0, pullOk: true);

  factory SyncEngineResult.busy() =>
      const SyncEngineResult(pulled: 0, pushed: 0, pullOk: true);
}
