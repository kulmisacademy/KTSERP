import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:inventrax_erp/l10n/app_localizations.dart';

import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_metric_card.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformDashboardPage extends ConsumerWidget {
  const PlatformDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(platformDashboardProvider);
    final analytics = ref.watch(platformAnalyticsProvider);
    final stores = ref.watch(platformStoresProvider(null));
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1400 ? 5 : (width >= 1000 ? 4 : (width >= 600 ? 2 : 1));

    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(platformRepositoryProvider).refreshAllMetrics();
        ref.invalidate(platformDashboardProvider);
        ref.invalidate(platformAnalyticsProvider);
        ref.invalidate(platformStoresProvider(null));
        await ref.read(platformDashboardProvider.future);
      },
      child: metrics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PlatformEmptyState(icon: Icons.error_outline, message: '$e'),
        data: (m) {
          if (m == null) {
            return const PlatformEmptyState(
              icon: Icons.cloud_off,
              message: 'Connect Supabase to load platform metrics.',
            );
          }
          return ListView(
            children: [
              PlatformHeroBanner(
                title: l10n.platformCommandCenter,
                subtitle: DateFormat.yMMMEd().format(DateTime.now()),
                trailing: stores.maybeWhen(
                  data: (s) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${m.activeStores}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'active of ${m.totalStores} stores',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                  orElse: () => null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final actionCols = c.maxWidth >= 700 ? 4 : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: actionCols,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.35,
                      children: [
                        PlatformQuickAction(
                          icon: Icons.storefront,
                          label: l10n.platformNavAllStores,
                          onTap: () => context.go('/platform/stores'),
                        ),
                        PlatformQuickAction(
                          icon: Icons.payments,
                          label: l10n.platformNavBilling,
                          color: AppColors.accent,
                          onTap: () => context.go('/platform/billing'),
                        ),
                        PlatformQuickAction(
                          icon: Icons.trending_up,
                          label: l10n.platformNavRevenue,
                          color: PlatformColors.gold,
                          onTap: () => context.go('/platform/revenue'),
                        ),
                        PlatformQuickAction(
                          icon: Icons.layers,
                          label: l10n.platformNavPlans,
                          onTap: () => context.go('/platform/plans'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              AppSpacing.gapMd(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 2.3,
                  ),
                  itemCount: 10,
                  itemBuilder: (_, i) => _metricAt(l10n, m, i),
                ),
              ),
              analytics.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (a) {
                  if (a == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      if (a.storeGrowth.isNotEmpty)
                        PlatformSectionCard(
                          title: l10n.platformStoreGrowth12m,
                          child: SizedBox(
                            height: 240,
                            child: SfCartesianChart(
                              primaryXAxis: const CategoryAxis(),
                              series: [
                                ColumnSeries<PlatformGrowthPoint, String>(
                                  dataSource: a.storeGrowth,
                                  xValueMapper: (p, _) => p.month,
                                  yValueMapper: (p, _) => p.count.toDouble(),
                                  color: AppColors.primary,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (a.subscriptionsByPlan.isNotEmpty)
                        PlatformSectionCard(
                          title: l10n.platformSubscriptionsByPlan,
                          child: SizedBox(
                            height: 240,
                            child: SfCartesianChart(
                              primaryXAxis: const CategoryAxis(),
                              series: [
                                ColumnSeries<PlatformPlanStat, String>(
                                  dataSource: a.subscriptionsByPlan,
                                  xValueMapper: (p, _) => p.planName,
                                  yValueMapper: (p, _) => p.storeCount.toDouble(),
                                  color: AppColors.accent,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (a.topStorageStores.isNotEmpty)
                        PlatformSectionCard(
                          title: l10n.platformTopStorageUsage,
                          trailing: TextButton(
                            onPressed: () => context.go('/platform/storage'),
                            child: Text(l10n.commonViewAll),
                          ),
                          child: Column(
                            children: a.topStorageStores.take(5).map(_storageRow).toList(),
                          ),
                        ),
                      stores.maybeWhen(
                        data: (list) => PlatformSectionCard(
                          title: l10n.platformRecentStores,
                          trailing: TextButton(
                            onPressed: () => context.go('/platform/stores'),
                            child: Text(l10n.commonViewAll),
                          ),
                          child: Column(
                            children: list.take(6).map((s) => _recentStoreRow(context, s)).toList(),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _metricAt(AppLocalizations l10n, PlatformDashboardMetrics m, int i) {
    final items = [
      AppMetricCard(title: l10n.platformTotalStores, value: '${m.totalStores}', icon: Icons.store, status: AppStatusType.info),
      AppMetricCard(title: l10n.acctStatusActive, value: '${m.activeStores}', icon: Icons.check_circle, status: AppStatusType.success),
      AppMetricCard(title: l10n.platformTrialStores, value: '${m.trialStores}', icon: Icons.hourglass_top, status: AppStatusType.warning),
      AppMetricCard(title: l10n.platformExpiredStores, value: '${m.expiredStores}', icon: Icons.event_busy, status: AppStatusType.error),
      AppMetricCard(title: l10n.platformMrr, value: formatMoney(m.mrrCents, currency: 'USD'), icon: Icons.payments, status: AppStatusType.success),
      AppMetricCard(title: l10n.platformPaidStores, value: '${m.paidStores}', icon: Icons.verified, status: AppStatusType.info),
      AppMetricCard(title: l10n.navProducts, value: '${m.totalProducts}', icon: Icons.inventory_2, status: AppStatusType.neutral),
      AppMetricCard(title: l10n.navSales, value: '${m.totalSales}', icon: Icons.receipt_long, status: AppStatusType.neutral),
      AppMetricCard(title: l10n.navUserManagement, value: '${m.totalUsers}', icon: Icons.people, status: AppStatusType.neutral),
      AppMetricCard(title: l10n.platformNavStorage, value: formatBytes(m.totalStorageBytes), icon: Icons.cloud, status: AppStatusType.warning),
    ];
    return items[i.clamp(0, items.length - 1)];
  }

  Widget _storageRow(PlatformStorageRank r) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(r.storeName),
      subtitle: Text('${r.imageCount} images'),
      trailing: Text(formatBytes(r.totalBytes), style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _recentStoreRow(BuildContext context, PlatformStoreRow s) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(s.storeName.isNotEmpty ? s.storeName[0] : '?')),
      title: Text(s.storeName),
      subtitle: Text('${s.ownerEmail ?? '—'} • ${s.planName ?? '—'}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/platform/stores/${s.storeId}'),
    );
  }
}
