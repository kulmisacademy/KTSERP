import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design_system.dart';
import '../../core/ux/web_interaction.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../core/l10n/sync_labels.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';
import '../connectivity_monitor.dart';
import '../sync_indicator_providers.dart';
import '../system_health_providers.dart';

/// Global sync / realtime / offline indicator — isolated rebuilds only.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    super.key,
    this.compact = true,
    this.tappable = true,
  });

  final bool compact;
  final bool tappable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = ref.watch(syncIndicatorUiProvider);
    final ui = localizeSyncUi(raw, context.l10n);

    final chip = RepaintBoundary(
      child: _StatusChip(
        state: ui.state,
        label: compact ? ui.compactLabel : ui.fullLabel,
        compact: compact,
        showQueueCount: ui.pendingQueue > 0 && !ui.offlineMode,
        queueCount: ui.pendingQueue,
      ),
    );

    if (!tappable) return chip;

    return WebInteraction.tap(
      onTap: () => context.push('/settings/health'),
      borderRadius: AppRadius.pillAll,
      child: chip,
    );
  }
}

/// Soft global strip — animates height without shifting the whole shell.
class CompactOfflineBanner extends ConsumerWidget {
  const CompactOfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(offlineBannerUiProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (!banner.visible) {
      return const SizedBox.shrink();
    }
    if (kIsWeb) {
      return _OfflineBannerBody(banner: banner, colorScheme: colorScheme);
    }
    return AnimatedSize(
      duration: AppAnimations.normal,
      curve: AppAnimations.standard,
      alignment: Alignment.topCenter,
      child: _OfflineBannerBody(banner: banner, colorScheme: colorScheme),
    );
  }
}

class _OfflineBannerBody extends ConsumerWidget {
  const _OfflineBannerBody({
    required this.banner,
    required this.colorScheme,
  });

  final OfflineBannerUi banner;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final offline = banner.offlineMode;
    final bg = offline
        ? colorScheme.tertiaryContainer
        : colorScheme.primaryContainer;
    final fg = offline
        ? colorScheme.onTertiaryContainer
        : colorScheme.onPrimaryContainer;
    final icon = offline ? Icons.cloud_off_outlined : Icons.cloud_queue_outlined;
    final message = offline
        ? l10n.syncOfflineBanner
        : l10n.syncQueueBanner(banner.pendingQueue);

    return Material(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppIcons.sm, color: fg),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (offline)
              TextButton(
                onPressed: () =>
                    ref.read(connectivityProvider.notifier).refresh(),
                child: Text(l10n.retry, style: TextStyle(color: fg)),
              ),
            TextButton(
              onPressed: () => context.push('/settings/health'),
              child: Text(l10n.details, style: TextStyle(color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.state,
    required this.label,
    required this.compact,
    this.showQueueCount = false,
    this.queueCount = 0,
  });

  final GlobalSyncIndicatorState state;
  final String label;
  final bool compact;
  final bool showQueueCount;
  final int queueCount;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final status = _statusType(state);
    final color = AppStatus.color(status, brightness: brightness);
    final displayLabel = showQueueCount && compact ? '$label $queueCount' : label;

    return SizedBox(
      width: compact ? 96 : null,
      height: compact ? 30 : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
          vertical: compact ? 0 : AppSpacing.xs,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppStatus.container(status, brightness: brightness),
          borderRadius: AppRadius.pillAll,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LiveDot(
              color: color,
              active: state == GlobalSyncIndicatorState.syncing,
            ),
            SizedBox(width: compact ? AppSpacing.xxs : AppSpacing.xs),
            Icon(_icon(state), size: compact ? AppIcons.xs : AppIcons.sm, color: color),
            SizedBox(width: compact ? AppSpacing.xxs : AppSpacing.xs),
            Flexible(
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static AppStatusType _statusType(GlobalSyncIndicatorState state) =>
      switch (state) {
        GlobalSyncIndicatorState.connected => AppStatusType.success,
        GlobalSyncIndicatorState.syncing => AppStatusType.info,
        GlobalSyncIndicatorState.warning => AppStatusType.warning,
        GlobalSyncIndicatorState.offline => AppStatusType.error,
      };

  static IconData _icon(GlobalSyncIndicatorState state) => switch (state) {
        GlobalSyncIndicatorState.connected => Icons.cloud_done_outlined,
        GlobalSyncIndicatorState.syncing => Icons.sync,
        GlobalSyncIndicatorState.warning => Icons.cloud_queue_outlined,
        GlobalSyncIndicatorState.offline => Icons.cloud_off_outlined,
      };
}

class _LiveDot extends StatelessWidget {
  const _LiveDot({
    required this.color,
    required this.active,
  });

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
    );
  }
}
