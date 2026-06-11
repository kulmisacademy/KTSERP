import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/design/design_system.dart';
import '../../../data/local/store_settings_provider.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformRevenuePage extends ConsumerWidget {
  const PlatformRevenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(platformDashboardProvider);
    final analytics = ref.watch(platformAnalyticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(platformDashboardProvider);
        ref.invalidate(platformAnalyticsProvider);
      },
      child: ListView(
        children: [
          const PlatformPageHeader(
            title: 'Revenue',
            subtitle: 'MRR, ARR, and plan contribution across the platform',
          ),
          metrics.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
            data: (m) {
              if (m == null) return const SizedBox.shrink();
              final arr = m.mrrCents * 12;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(child: _RevenueTile(label: 'MRR', value: formatMoney(m.mrrCents, currency: 'USD'), icon: Icons.calendar_month)),
                    AppSpacing.gapMd(),
                    Expanded(child: _RevenueTile(label: 'ARR (est.)', value: formatMoney(arr, currency: 'USD'), icon: Icons.show_chart)),
                    AppSpacing.gapMd(),
                    Expanded(child: _RevenueTile(label: 'Paid stores', value: '${m.paidStores}', icon: Icons.verified)),
                    AppSpacing.gapMd(),
                    Expanded(child: _RevenueTile(label: 'Trial stores', value: '${m.trialStores}', icon: Icons.hourglass_empty)),
                  ],
                ),
              );
            },
          ),
          analytics.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (a) {
              if (a == null || a.subscriptionsByPlan.isEmpty) {
                return const PlatformEmptyState(icon: Icons.bar_chart, message: 'No revenue breakdown yet');
              }
              return Column(
                children: [
                  PlatformSectionCard(
                    title: 'MRR by plan',
                    child: SizedBox(
                      height: 280,
                      child: SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: const NumericAxis(),
                        series: [
                          ColumnSeries<PlatformPlanStat, String>(
                            dataSource: a.subscriptionsByPlan,
                            xValueMapper: (p, _) => p.planName,
                            yValueMapper: (p, _) => (p.mrrCents / 100).toDouble(),
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  PlatformSectionCard(
                    title: 'Plan breakdown',
                    child: Column(
                      children: a.subscriptionsByPlan.map((p) {
                        return ListTile(
                          title: Text(p.planName),
                          subtitle: Text('${p.storeCount} stores'),
                          trailing: Text(
                            formatMoney(p.mrrCents, currency: 'USD'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RevenueTile extends StatelessWidget {
  const _RevenueTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            AppSpacing.gapSm(),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
