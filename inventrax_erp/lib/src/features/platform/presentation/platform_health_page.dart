import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../observability/observability_hub.dart';
import '../../../observability/system_health_providers.dart';
import '../../../ui/components/app_metric_card.dart';
import '../../../ui/components/app_section_header.dart';
import '../application/platform_health_providers.dart';

/// Platform-level health view (sync observability + cloud payment metrics).
class PlatformHealthPage extends ConsumerWidget {
  const PlatformHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final health = ref.watch(systemHealthSnapshotProvider);
    final overview = ref.watch(platformHealthOverviewProvider);

    return health.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.platformHealthUnavailable(e.toString()))),
      data: (h) => ListView(
        padding: AppSpacing.page,
        children: [
          Text(
            l10n.platformSystemHealthTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          AppSpacing.gapMd(),
          overview.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (o) {
              if (o == null) return const SizedBox.shrink();
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 1,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 2.5,
                children: [
                  AppMetricCard(
                    title: l10n.platformPendingSync,
                    value: '${o.pendingSync}',
                    icon: Icons.sync,
                    status: o.pendingSync > 20
                        ? AppStatusType.warning
                        : AppStatusType.success,
                  ),
                  AppMetricCard(
                    title: l10n.platformFailedPushes,
                    value: '${o.failedSync}',
                    icon: Icons.error_outline,
                    status: o.failedSync > 0
                        ? AppStatusType.error
                        : AppStatusType.success,
                  ),
                  AppMetricCard(
                    title: l10n.platformRealtimeStatus,
                    value: o.realtimeState,
                    icon: Icons.podcasts_outlined,
                    status: o.realtimeState == 'connected'
                        ? AppStatusType.success
                        : AppStatusType.warning,
                  ),
                  AppMetricCard(
                    title: l10n.platformFailedPayments24h,
                    value: '${o.failedPayments24h}',
                    icon: Icons.payments_outlined,
                    status: o.failedPayments24h > 0
                        ? AppStatusType.error
                        : AppStatusType.success,
                  ),
                  AppMetricCard(
                    title: l10n.platformFailedPayments30d,
                    value: '${o.failedPayments30d}',
                    icon: Icons.warning_amber_outlined,
                    status: o.failedPayments30d > 0
                        ? AppStatusType.warning
                        : AppStatusType.success,
                  ),
                  AppMetricCard(
                    title: l10n.platformProductsSessionStore,
                    value: '${h.productCount}',
                    icon: Icons.inventory_2_outlined,
                    status: AppStatusType.neutral,
                  ),
                ],
              );
            },
          ),
          AppSpacing.gapLg(),
          AppSectionHeader(title: l10n.platformEventLog),
          AppSpacing.gapSm(),
          ...h.hub.recentEvents(limit: 15).map(
                (e) => ListTile(
                  dense: true,
                  leading: Icon(_levelIcon(e.level), size: 18),
                  title: Text('[${e.category}] ${e.message}'),
                  subtitle: Text(DateFormat.yMd().add_Hms().format(e.at)),
                ),
              ),
          AppSpacing.gapMd(),
          OutlinedButton.icon(
            onPressed: () => context.go('/settings/health'),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.platformOpenFullHealth),
          ),
        ],
      ),
    );
  }

  static IconData _levelIcon(ObservabilityLevel l) => switch (l) {
        ObservabilityLevel.info => Icons.info_outline,
        ObservabilityLevel.warning => Icons.warning_amber_outlined,
        ObservabilityLevel.error => Icons.error_outline,
      };
}
