import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/store_context.dart';
import '../../../data/local/db_provider.dart';
import '../../../observability/observability_hub.dart';
import '../../../observability/system_health_providers.dart';
import '../../../observability/widgets/sync_status_indicator.dart';
import '../../../sync/sync_queue_page.dart';
import '../../../sync/sync_service.dart';
import '../../../core/design/design_system.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_metric_card.dart';
import '../../../ui/components/app_section_header.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/components/app_status_badge.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/layout/app_shell.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';
import '../../users/domain/app_permission.dart';

class SystemHealthPage extends ConsumerStatefulWidget {
  const SystemHealthPage({super.key});

  @override
  ConsumerState<SystemHealthPage> createState() => _SystemHealthPageState();
}

class _SystemHealthPageState extends ConsumerState<SystemHealthPage> {
  var _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(systemHealthSnapshotProvider);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canManage = StoreContext.can(AppPermission.settingsManage) ||
        StoreContext.isStoreOwner;

    final health = ref.watch(systemHealthSnapshotProvider);

    return AppShell(
      title: l10n.healthTitle,
      actions: [
        IconButton(
          onPressed: _refreshing ? null : _refresh,
          icon: _refreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          tooltip: l10n.healthRefreshMetrics,
        ),
      ],
      child: health.when(
        data: (snap) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: AppSpacing.only(bottom: AppSpacing.lg),
            children: [
              CompactOfflineBanner(),
              AppSpacing.gapSm(),
              _HealthHeroCard(snap: snap, l10n: l10n),
              AppSpacing.gapMd(),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SizedBox(
                    width: 200,
                    child: AppMetricCard(
                      title: l10n.healthRealtime,
                      value: _realtimeLabel(l10n, snap.realtimeState),
                      icon: Icons.podcasts_outlined,
                      status: _realtimeStatus(snap.realtimeState),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: AppMetricCard(
                      title: l10n.healthSync,
                      value: snap.syncStatus.health.name,
                      icon: Icons.sync,
                      status: AppStatus.forSyncHealth(snap.syncStatus.health.name),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: AppMetricCard(
                      title: l10n.healthQueue,
                      value: '${snap.pendingQueue}',
                      subtitle: l10n.healthQueueRetries(snap.failedQueue),
                      icon: Icons.queue,
                      status: snap.pendingQueue > 0
                          ? AppStatusType.warning
                          : AppStatusType.success,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: AppMetricCard(
                      title: l10n.healthNetwork,
                      value: snap.isOnline ? l10n.healthOnline : l10n.healthOffline,
                      icon: Icons.wifi,
                      status: AppStatus.forOnline(snap.isOnline),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd(),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(title: l10n.healthSyncTimeline),
                    AppSpacing.gapSm(),
                    _InfoRow(
                      l10n.healthLastPull,
                      _fmt(snap.lastPulledAt),
                    ),
                    _InfoRow(
                      l10n.healthLastPush,
                      _fmt(snap.lastPushedAt),
                    ),
                    _InfoRow(
                      l10n.healthLastSuccess,
                      _fmt(snap.hub.lastSyncSuccessAt),
                    ),
                    if (snap.hub.lastSyncError != null)
                      _InfoRow(
                        l10n.healthLastError,
                        snap.hub.lastSyncError!,
                        valueColor: AppColors.error,
                      ),
                    _InfoRow(
                      l10n.healthCloudConfigured,
                      snap.supabaseConfigured ? l10n.healthYes : l10n.healthNo,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapSm(),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(title: l10n.healthBackgroundScheduler),
                    AppSpacing.gapSm(),
                    _InfoRow(
                      l10n.healthRunning,
                      snap.scheduler.running ? l10n.healthYes : l10n.healthNo,
                    ),
                    _InfoRow(
                      l10n.healthInterval,
                      l10n.healthSecondsShort(snap.scheduler.intervalSeconds),
                    ),
                    _InfoRow(
                      l10n.healthLastCycle,
                      _fmt(snap.scheduler.lastTickAt),
                    ),
                    _InfoRow(
                      l10n.healthInProgress,
                      snap.scheduler.tickInProgress ? l10n.healthYes : l10n.healthNo,
                    ),
                    if (snap.scheduler.lastError != null)
                      _InfoRow(
                        l10n.healthLastError,
                        snap.scheduler.lastError!,
                        valueColor: AppColors.warning,
                      ),
                  ],
                ),
              ),
              AppSpacing.gapSm(),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(title: l10n.healthLocalDatabase),
                    AppSpacing.gapSm(),
                    _InfoRow(l10n.healthCachedProducts, '${snap.productCount}'),
                    _InfoRow(
                      l10n.healthDbFileSize,
                      snap.localDbBytes != null
                          ? l10n.healthDbFileSizeMb(
                              (snap.localDbBytes! / (1024 * 1024)).toStringAsFixed(2),
                            )
                          : l10n.healthDbFileSizeWeb,
                    ),
                    _InfoRow(
                      l10n.healthQueueMaxRetries,
                      '${snap.maxRetriesQueue}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.healthQueueInspector,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/sync'),
                          child: Text(l10n.healthOpenFullQueue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 220,
                      child: _QueuePreview(),
                    ),
                  ],
                ),
              ),
              if (canManage) ...[
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.healthRecoveryActions,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.healthRecoverySubtitle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppButton(
                            label: l10n.healthRetryFailedSync,
                            icon: Icons.replay,
                            onPressed: () => _retryFailed(ref),
                          ),
                          AppButton(
                            label: l10n.healthForceFullSync,
                            icon: Icons.cloud_sync,
                            onPressed: () => _forceFullSync(ref),
                          ),
                          AppButton(
                            label: l10n.healthClearHydrationCache,
                            icon: Icons.cleaning_services_outlined,
                            onPressed: () => _clearHydrationCache(ref),
                          ),
                          AppButton(
                            label: l10n.healthRebuildIndexes,
                            icon: Icons.storage,
                            onPressed: () => _rebuildIndexes(ref),
                          ),
                          AppButton(
                            label: l10n.healthQaValidation,
                            icon: Icons.fact_check_outlined,
                            onPressed: () => context.push('/settings/qa'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.healthRealtimeEventLog,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...snap.hub.recentEvents(limit: 25).map(
                          (e) => ListTile(
                            dense: true,
                            leading: Icon(
                              _levelIcon(e.level),
                              size: AppIcons.sm,
                              color: AppStatus.color(
                                _levelStatus(e.level),
                                brightness: Theme.of(context).brightness,
                              ),
                            ),
                            title: Text('[${e.category}] ${e.message}'),
                            subtitle: Text(
                              DateFormat.yMd().add_Hms().format(e.at),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.healthErrorDetail(e.toString()))),
      ),
    );
  }

  String _fmt(DateTime? dt) =>
      dt == null ? '—' : DateFormat.yMd().add_Hms().format(dt);

  static String _realtimeLabel(AppLocalizations l10n, RealtimeConnectionState s) =>
      switch (s) {
        RealtimeConnectionState.connected => l10n.healthRealtimeConnected,
        RealtimeConnectionState.reconnecting => l10n.healthRealtimeReconnecting,
        RealtimeConnectionState.disconnected => l10n.healthRealtimeDisconnected,
        RealtimeConnectionState.failed => l10n.healthRealtimeFailed,
      };

  static AppStatusType _realtimeStatus(RealtimeConnectionState s) =>
      switch (s) {
        RealtimeConnectionState.connected => AppStatusType.success,
        RealtimeConnectionState.reconnecting => AppStatusType.warning,
        RealtimeConnectionState.disconnected => AppStatusType.neutral,
        RealtimeConnectionState.failed => AppStatusType.error,
      };

  static IconData _levelIcon(ObservabilityLevel l) => switch (l) {
        ObservabilityLevel.info => Icons.info_outline,
        ObservabilityLevel.warning => Icons.warning_amber_outlined,
        ObservabilityLevel.error => Icons.error_outline,
      };

  static AppStatusType _levelStatus(ObservabilityLevel l) => switch (l) {
        ObservabilityLevel.info => AppStatusType.info,
        ObservabilityLevel.warning => AppStatusType.warning,
        ObservabilityLevel.error => AppStatusType.error,
      };

  Future<void> _retryFailed(WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    await db.resetFailedSyncRetries(storeId: StoreContext.storeId);
    await ref.read(syncWorkerProvider.notifier).pushNow();
    ref.invalidate(systemHealthSnapshotProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.healthRetryingFailedSync)),
      );
    }
  }

  Future<void> _forceFullSync(WidgetRef ref) async {
    await ref.read(syncWorkerProvider.notifier).fullSync(forceFullPull: true);
    ref.invalidate(systemHealthSnapshotProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.healthFullSyncCompleted)),
      );
    }
  }

  Future<void> _clearHydrationCache(WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    await db.clearSyncHydrationCache(storeId: StoreContext.storeId);
    ref.invalidate(systemHealthSnapshotProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.healthHydrationCleared)),
      );
    }
  }

  Future<void> _rebuildIndexes(WidgetRef ref) async {
    await ref.read(appDatabaseProvider).rebuildLocalIndexes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.healthIndexesRebuilt)),
      );
    }
  }
}

class _QueuePreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(syncQueueProvider);
    return rows.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text(context.l10n.healthQueueEmpty));
        }
        return ListView.builder(
          itemCount: items.length.clamp(0, 8),
          itemBuilder: (context, i) {
            final q = items[i];
            return ListTile(
              dense: true,
              title: Text('${q.entity} · ${q.operation}'),
              subtitle: Text(
                'id=${q.entityId} · retries=${q.retryCount}'
                '${q.lastError != null ? '\n${q.lastError}' : ''}',
              ),
              isThreeLine: q.lastError != null,
            );
          },
        );
      },
      loading: () => const ListPageSkeleton(itemCount: 3, showHeader: false),
      error: (e, _) => Text(userFriendlyError(e)),
    );
  }
}

class _HealthHeroCard extends StatelessWidget {
  const _HealthHeroCard({required this.snap, required this.l10n});

  final SystemHealthSnapshot snap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final (label, status, icon) = switch (snap.indicatorState) {
      GlobalSyncIndicatorState.connected => (
          l10n.healthAllOperational,
          AppStatusType.success,
          Icons.verified_outlined,
        ),
      GlobalSyncIndicatorState.syncing => (
          l10n.healthSyncInProgress,
          AppStatusType.info,
          Icons.sync,
        ),
      GlobalSyncIndicatorState.warning => (
          l10n.healthAttentionNeeded,
          AppStatusType.warning,
          Icons.warning_amber_rounded,
        ),
      GlobalSyncIndicatorState.offline => (
          l10n.healthOfflineLocalMode,
          AppStatusType.error,
          Icons.cloud_off_outlined,
        ),
    };
    final color = AppStatus.color(status, brightness: brightness);

    return AppCard(
      elevated: true,
      padding: AppSpacing.cardLg,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: AppStatus.container(status, brightness: brightness),
              borderRadius: AppRadius.lgAll,
            ),
            child: Icon(icon, color: color, size: AppIcons.xl),
          ),
          AppSpacing.gapMd(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AppStatusBadge(
                      label: switch (status) {
                        AppStatusType.success => l10n.healthBadgeHealthy,
                        AppStatusType.info => l10n.healthBadgeActive,
                        AppStatusType.warning => l10n.healthBadgeReview,
                        AppStatusType.error => l10n.healthBadgeOffline,
                        AppStatusType.neutral => l10n.healthBadgeIdle,
                      },
                      type: status,
                      compact: true,
                    ),
                  ],
                ),
                AppSpacing.gapXxs(),
                Text(
                  snap.offlineMode
                      ? l10n.healthOfflineSalesStored
                      : l10n.healthQueuedRetryingRealtime(
                          snap.pendingQueue,
                          snap.failedQueue,
                          _SystemHealthPageState._realtimeLabel(
                            l10n,
                            snap.realtimeState,
                          ),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
