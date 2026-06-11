import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/store/active_store_scope.dart';
import '../core/store_context.dart';
import '../core/supabase_config.dart';
import '../data/local/app_database.dart';
import '../data/local/db_provider.dart';
import '../features/billing/application/subscription_lock_provider.dart';
import 'sync_engine.dart';
import 'sync_push_service.dart';
import 'supabase_bootstrap.dart';

enum SyncHealth { offline, queued, syncing, synced }

class SyncStatus {
  const SyncStatus({
    required this.health,
    required this.pendingCount,
    this.lastPulled,
    this.lastPushed,
    this.lastSuccessAt,
  });

  final SyncHealth health;
  final int pendingCount;
  final int? lastPulled;
  final int? lastPushed;
  final DateTime? lastSuccessAt;

  SyncStatus copyWith({
    SyncHealth? health,
    int? pendingCount,
    int? lastPulled,
    int? lastPushed,
    DateTime? lastSuccessAt,
  }) =>
      SyncStatus(
        health: health ?? this.health,
        pendingCount: pendingCount ?? this.pendingCount,
        lastPulled: lastPulled ?? this.lastPulled,
        lastPushed: lastPushed ?? this.lastPushed,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      );
}

/// Observes sync queue and runs bidirectional sync (pull then push).
class SyncWorker extends Notifier<SyncStatus> {
  AppDatabase get _db => ref.read(appDatabaseProvider);

  StreamSubscription<int>? _sub;
  Timer? _countDebounce;
  bool _initialPullDone = false;
  bool _syncInFlight = false;
  String? _boundStoreId;
  String? _boundTenantId;

  @override
  SyncStatus build() {
    ref.watch(appDatabaseProvider);
    final scope = ref.watch(activeStoreScopeProvider);

    ref.listen(activeStoreScopeProvider, (prev, next) {
      if (prev?.storeId != next.storeId || prev?.tenantId != next.tenantId) {
        _initialPullDone = false;
        _bindQueueWatch(tenantId: next.tenantId, storeId: next.storeId);
        if (SupabaseConfig.isConfigured && StoreContext.isLoggedIn) {
          Future.microtask(_trySync);
        }
      }
    });

    _bindQueueWatch(tenantId: scope.tenantId, storeId: scope.storeId);

    if (SupabaseConfig.isConfigured && StoreContext.isLoggedIn) {
      Future.microtask(_purgeOrphanQueue);
      Future.microtask(_trySync);
    }

    ref.onDispose(() {
      _sub?.cancel();
      _countDebounce?.cancel();
    });

    return const SyncStatus(health: SyncHealth.synced, pendingCount: 0);
  }

  void _bindQueueWatch({
    required String tenantId,
    required String storeId,
  }) {
    if (_boundStoreId == storeId &&
        _boundTenantId == tenantId &&
        _sub != null) {
      return;
    }
    _boundStoreId = storeId;
    _boundTenantId = tenantId;
    _sub?.cancel();
    _sub = _db
        .watchPendingSyncCount(tenantId: tenantId, storeId: storeId)
        .listen((count) {
      if (kDebugMode) {
        debugPrint('QUEUE STORE: $storeId');
        debugPrint('QUEUE TENANT: $tenantId');
        debugPrint('QUEUE COUNT: $count');
      }
      _updateFromCount(count);
      if (count > 0 && SupabaseConfig.isConfigured) {
        Future.microtask(_trySync);
      }
    });
  }

  void _updateFromCount(int count) {
    _countDebounce?.cancel();
    _countDebounce = Timer(const Duration(milliseconds: 200), () {
      final SyncHealth health;
      if (count == 0) {
        health = SyncHealth.synced;
      } else if (!SupabaseConfig.isConfigured) {
        health = SyncHealth.offline;
      } else {
        health = SyncHealth.queued;
      }
      state = state.copyWith(health: health, pendingCount: count);
    });
  }

  Future<void> _purgeOrphanQueue() async {
    final storeId = StoreContext.storeId;
    final tenantId = StoreContext.tenantId;
    if (storeId.isEmpty ||
        tenantId.isEmpty ||
        storeId == StoreContext.defaultStoreId) {
      return;
    }
    await _db.cleanupForeignTenantData(
      tenantId: tenantId,
      storeId: storeId,
    );
  }

  /// Full sync: pull cloud data, then push pending queue.
  Future<SyncEngineResult> fullSync({bool forceFullPull = false}) async {
    if (!SupabaseConfig.isConfigured || supabaseClient == null) {
      return SyncEngineResult.offline();
    }
    if (ref.read(subscriptionLockProvider).isLocked) {
      return SyncEngineResult.offline();
    }
    state = state.copyWith(health: SyncHealth.syncing);
    final result = await SyncEngine(_db).fullSync(forceFullPull: forceFullPull);
    _initialPullDone = true;
    final remaining = await _db
        .watchPendingSyncCount(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
        )
        .first;
    _updateFromCount(remaining);
    if (kDebugMode && remaining > 0 && result.pushed == 0) {
      debugPrint(
        'Sync: $remaining queue item(s) remain after push — '
        'open /sync to inspect errors',
      );
    }
    state = state.copyWith(
      lastPulled: result.pulled,
      lastPushed: result.pushed,
      lastSuccessAt: DateTime.now(),
    );
    return result;
  }

  Future<int> pushNow() async {
    if (!SupabaseConfig.isConfigured) return 0;
    if (ref.read(subscriptionLockProvider).isLocked) return 0;
    state = state.copyWith(health: SyncHealth.syncing);
    final pushed = await SyncPushService(_db).pushPending();
    final remaining = await _db
        .watchPendingSyncCount(
          tenantId: StoreContext.tenantId,
          storeId: StoreContext.storeId,
        )
        .first;
    _updateFromCount(remaining);
    state = state.copyWith(lastPushed: pushed);
    return pushed;
  }

  Future<void> _trySync() async {
    if (_syncInFlight) return;
    if (supabaseClient == null || !StoreContext.isLoggedIn) return;
    if (ref.read(subscriptionLockProvider).isLocked) return;

    _syncInFlight = true;
    state = state.copyWith(health: SyncHealth.syncing);
    try {
      final engine = SyncEngine(_db);
      if (!_initialPullDone) {
        await engine.fullSync(forceFullPull: true);
        _initialPullDone = true;
      } else {
        await engine.fullSync();
      }

      final count = await _db
          .watchPendingSyncCount(
            tenantId: StoreContext.tenantId,
            storeId: StoreContext.storeId,
          )
          .first;
      _updateFromCount(count);
      state = state.copyWith(lastSuccessAt: DateTime.now());
    } finally {
      _syncInFlight = false;
    }
  }

}

final syncWorkerProvider = NotifierProvider<SyncWorker, SyncStatus>(
  SyncWorker.new,
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref.watch(appDatabaseProvider));
});
