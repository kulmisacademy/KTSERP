import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/supabase_config.dart';
import '../sync/sync_service.dart';
import 'connectivity_monitor.dart';
import 'observability_hub.dart';
import 'realtime_hub_provider.dart';
import 'system_health_providers.dart';

/// Lightweight sync chip state — no DB round-trips, minimal rebuild surface.
class SyncIndicatorUi {
  const SyncIndicatorUi({
    required this.state,
    required this.compactLabel,
    required this.fullLabel,
    required this.offlineMode,
    required this.pendingQueue,
  });

  final GlobalSyncIndicatorState state;
  final String compactLabel;
  final String fullLabel;
  final bool offlineMode;
  final int pendingQueue;
}

final syncIndicatorUiProvider = Provider<SyncIndicatorUi>((ref) {
  final sync = ref.watch(
    syncWorkerProvider.select((s) => (s.health, s.pendingCount)),
  );
  final isOnline = ref.watch(connectivityProvider);
  final configured = SupabaseConfig.isConfigured;
  final offlineMode = !isOnline || !configured;
  final pending = sync.$2;
  final health = sync.$1;

  // Realtime hub ticks retrigger the chip on web — skip unless queue/sync active.
  final realtime = kIsWeb && pending == 0 && health != SyncHealth.syncing
      ? RealtimeConnectionState.connected
      : ref.watch(realtimeConnectionProvider);

  GlobalSyncIndicatorState state;
  if (offlineMode) {
    state = GlobalSyncIndicatorState.offline;
  } else if (health == SyncHealth.syncing && pending > 0) {
    // Background pulls with an empty queue should not flash the global chip.
    state = GlobalSyncIndicatorState.syncing;
  } else if (health == SyncHealth.queued || pending > 0) {
    state = GlobalSyncIndicatorState.warning;
  } else if (realtime == RealtimeConnectionState.connected) {
    state = GlobalSyncIndicatorState.connected;
  } else {
    state = GlobalSyncIndicatorState.warning;
  }

  String compact;
  String full;
  if (offlineMode) {
    compact = 'Offline';
    full = 'OFFLINE MODE';
  } else {
    switch (state) {
      case GlobalSyncIndicatorState.syncing:
        compact = 'Sync';
        full = 'Syncing…';
      case GlobalSyncIndicatorState.warning:
        compact = pending > 0 ? 'Queue' : 'Sync';
        full = pending > 0 ? 'Queue $pending' : 'Reconnecting';
      case GlobalSyncIndicatorState.connected:
        compact = 'Live';
        full = 'Connected';
      case GlobalSyncIndicatorState.offline:
        compact = 'Offline';
        full = 'OFFLINE MODE';
    }
  }

  return SyncIndicatorUi(
    state: state,
    compactLabel: compact,
    fullLabel: full,
    offlineMode: offlineMode,
    pendingQueue: pending,
  );
});

/// Offline / queue strip — isolated from full health snapshot.
class OfflineBannerUi {
  const OfflineBannerUi({
    required this.offlineMode,
    required this.pendingQueue,
  });

  final bool offlineMode;
  final int pendingQueue;

  bool get visible => offlineMode || pendingQueue > 0;
}

final offlineBannerUiProvider = Provider<OfflineBannerUi>((ref) {
  final pending = ref.watch(syncWorkerProvider.select((s) => s.pendingCount));
  final isOnline = ref.watch(connectivityProvider);
  final configured = SupabaseConfig.isConfigured;
  return OfflineBannerUi(
    offlineMode: !isOnline || !configured,
    pendingQueue: pending,
  );
});
