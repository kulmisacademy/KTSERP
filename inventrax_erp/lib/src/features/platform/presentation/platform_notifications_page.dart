import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design_system.dart';
import '../../../ui/components/app_status_badge.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformNotificationsPage extends ConsumerWidget {
  const PlatformNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(platformAnalyticsProvider);

    return analytics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
      data: (data) {
        final alerts = data?.alerts ?? [];
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(platformAnalyticsProvider);
            await ref.read(platformAnalyticsProvider.future);
          },
          child: ListView(
            children: [
              const PlatformPageHeader(
                title: 'Alerts',
                subtitle: 'Expired subscriptions, trials ending, and storage warnings',
              ),
              if (alerts.isEmpty)
                const PlatformEmptyState(
                  icon: Icons.check_circle_outline,
                  message: 'All clear — no platform alerts right now.',
                )
              else
                ...alerts.map((a) => _AlertCard(alert: a)),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final PlatformAlert alert;

  @override
  Widget build(BuildContext context) {
    final type = switch (alert.type) {
      'expired_subscription' => AppStatusType.error,
      'trial_ending' => AppStatusType.warning,
      'high_storage' => AppStatusType.warning,
      _ => AppStatusType.neutral,
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppStatus.container(type, brightness: Brightness.light),
            borderRadius: AppRadius.mdAll,
          ),
          child: Icon(_iconFor(alert.type), color: AppStatus.color(type, brightness: Brightness.light)),
        ),
        title: Text(alert.storeName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(alert.message),
        trailing: AppStatusBadge(label: alert.type.replaceAll('_', ' '), type: type),
        onTap: alert.storeId.isEmpty ? null : () => context.go('/platform/stores/${alert.storeId}'),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'expired_subscription' => Icons.event_busy,
        'trial_ending' => Icons.hourglass_bottom,
        'high_storage' => Icons.cloud_upload,
        _ => Icons.notifications,
      };
}
