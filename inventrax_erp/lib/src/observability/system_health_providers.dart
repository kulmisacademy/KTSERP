import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/store_context.dart';
import '../core/supabase_config.dart';
import '../data/local/db_provider.dart';
import '../sync/sync_service.dart';
import 'connectivity_monitor.dart';
import 'observability_hub.dart';
import 'realtime_hub_provider.dart';

class SystemHealthSnapshot {
  const SystemHealthSnapshot({
    required this.isOnline,
    required this.supabaseConfigured,
    required this.syncStatus,
    required this.realtimeState,
    required this.scheduler,
    required this.pendingQueue,
    required this.failedQueue,
    required this.maxRetriesQueue,
    required this.productCount,
    required this.localDbBytes,
    required this.hub,
    required this.lastPulledAt,
    required this.lastPushedAt,
  });

  final bool isOnline;
  final bool supabaseConfigured;
  final SyncStatus syncStatus;
  final RealtimeConnectionState realtimeState;
  final SchedulerSnapshot scheduler;
  final int pendingQueue;
  final int failedQueue;
  final int maxRetriesQueue;
  final int productCount;
  final int? localDbBytes;
  final ObservabilityHub hub;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;

  bool get offlineMode => !isOnline || !supabaseConfigured;

  GlobalSyncIndicatorState get indicatorState {
    if (offlineMode) return GlobalSyncIndicatorState.offline;
    if (syncStatus.health == SyncHealth.syncing) {
      return GlobalSyncIndicatorState.syncing;
    }
    if (syncStatus.health == SyncHealth.queued || failedQueue > 0) {
      return GlobalSyncIndicatorState.warning;
    }
    if (realtimeState == RealtimeConnectionState.connected) {
      return GlobalSyncIndicatorState.connected;
    }
    return GlobalSyncIndicatorState.warning;
  }
}

enum GlobalSyncIndicatorState { connected, syncing, warning, offline }

final systemHealthSnapshotProvider =
    FutureProvider.autoDispose<SystemHealthSnapshot>((ref) async {
  ref.watch(connectivityProvider);
  ref.watch(realtimeHubTickProvider);
  final db = ref.watch(appDatabaseProvider);
  final tenantId = StoreContext.tenantId;
  final storeId = StoreContext.storeId;
  final syncStatus = ref.watch(syncWorkerProvider);
  final isOnline = ref.watch(connectivityProvider);
  final hub = ObservabilityHub.instance;

  final queue = await db
      .watchSyncQueue(tenantId: tenantId, storeId: storeId)
      .first;
  final failed = queue.where((q) => q.retryCount > 0).length;
  final maxed = queue.where((q) => q.retryCount >= 10).length;
  final products = await db.countProducts(
    tenantId: tenantId,
    storeId: storeId,
  );

  DateTime? lastPull;
  DateTime? lastPush;
  for (final entity in ['all', 'products', 'sales']) {
    final t = await db.getLastPulledAt(storeId: storeId, entity: entity);
    if (t != null && (lastPull == null || t.isAfter(lastPull))) lastPull = t;
  }
  lastPush = hub.lastPushAt;

  int? dbBytes;
  if (!kIsWeb) {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'inventrax.sqlite'));
      if (await file.exists()) {
        dbBytes = await file.length();
      }
    } catch (_) {}
  }

  return SystemHealthSnapshot(
    isOnline: isOnline,
    supabaseConfigured: SupabaseConfig.isConfigured,
    syncStatus: syncStatus,
    realtimeState: hub.realtimeState,
    scheduler: hub.scheduler,
    pendingQueue: syncStatus.pendingCount,
    failedQueue: failed,
    maxRetriesQueue: maxed,
    productCount: products,
    localDbBytes: dbBytes,
    hub: hub,
    lastPulledAt: lastPull ?? hub.lastPullAt,
    lastPushedAt: lastPush ?? hub.lastPushAt,
  );
});
