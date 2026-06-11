import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design_system.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformStoragePage extends ConsumerWidget {
  const PlatformStoragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(platformDashboardProvider);
    final analytics = ref.watch(platformAnalyticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(platformRepositoryProvider).refreshAllMetrics();
        ref.invalidate(platformAnalyticsProvider);
        ref.invalidate(platformDashboardProvider);
      },
      child: ListView(
        children: [
          const PlatformPageHeader(
            title: 'Storage',
            subtitle: 'Platform-wide file usage and top consuming stores',
          ),
          metrics.when(
            data: (m) => m == null
                ? const SizedBox.shrink()
                : PlatformHeroBanner(
                    title: 'Total platform storage',
                    subtitle: 'Product images, logos, and attachments',
                    trailing: Text(
                      formatBytes(m.totalStorageBytes),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          analytics.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
            data: (a) {
              final list = a?.topStorageStores ?? [];
              if (list.isEmpty) {
                return const PlatformEmptyState(
                  icon: Icons.cloud_queue,
                  message: 'No storage data yet. Pull to refresh.',
                );
              }
              return PlatformSectionCard(
                title: 'Top storage consumers',
                child: Column(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      _StorageRankTile(rank: i + 1, item: list[i]),
                      if (i < list.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StorageRankTile extends StatelessWidget {
  const _StorageRankTile({required this.rank, required this.item});

  final int rank;
  final PlatformStorageRank item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
      title: Text(item.storeName),
      subtitle: Text('${item.imageCount} images'),
      trailing: Text(formatBytes(item.totalBytes), style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () => context.go('/platform/stores/${item.storeId}'),
    );
  }
}
