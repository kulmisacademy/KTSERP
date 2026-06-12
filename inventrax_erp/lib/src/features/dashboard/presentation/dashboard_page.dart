import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/design/design_system.dart';
import '../../../core/store_context.dart';
import '../../users/domain/app_permission.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_metric_card.dart';
import '../../../ui/components/app_section_header.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/layout/app_shell.dart';
import '../../../ui/widgets/brand_hero_banner.dart';
import '../dashboard_providers.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kpis = ref.watch(dashboardKpisProvider);
    final debtAlerts = ref.watch(dashboardDebtAlertsProvider);
    final trend = ref.watch(salesTrendProvider);
    final lowStock = ref.watch(lowStockProvider);
    final recentSales = ref.watch(recentSalesProvider);
    final settings = ref.watch(storeSettingsProvider);
    final ctxStore = StoreContext.storeName?.trim();
    final storeName = (ctxStore != null && ctxStore.isNotEmpty)
        ? ctxStore
        : (settings.value?.storeName ?? l10n.dashboardYourStore);
    final currency = settings.value?.currencyCode ?? 'USD';
    final todaySalesLabel = kpis.maybeWhen(
      data: (k) => formatMoney(k.todaySalesCents, currency: currency),
      orElse: () => '—',
    );
    final isWide = Responsive.isDesktop(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final dateLabel =
        DateFormat.yMMMEd(localeCode).format(DateTime.now());
    final canReports = StoreContext.can(AppPermission.reportsView);
    final canExpenses = StoreContext.can(AppPermission.expensesView);
    final canProducts = StoreContext.can(AppPermission.productsView);
    final canPos = StoreContext.can(AppPermission.posCheckout);
    final canPurchases = StoreContext.can(AppPermission.purchasesCreate);

    return AppShell(
      route: '/dashboard',
      subtitle: dateLabel,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _WelcomeBanner(
              storeName: storeName,
              dateLabel: dateLabel,
              todaySales: todaySalesLabel,
              onOpenPos: canPos ? () => context.go('/pos') : null,
            ),
          ),
          debtAlerts.when(
            skipLoadingOnReload: true,
            data: (alerts) {
              if (!alerts.hasAlerts) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverPadding(
                padding: AppSpacing.only(top: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _DebtAlertsBanner(
                    alerts: alerts,
                    onViewDebts: () => context.go('/debts'),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          if (canReports || canExpenses)
            SliverPadding(
              padding: AppSpacing.only(top: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: kpis.when(
                  skipLoadingOnReload: true,
                  data: (kpi) => _KpiGrid(
                    kpis: kpi,
                    currency: currency,
                    crossAxisCount: Responsive.isMobile(context)
                        ? 1
                        : (Responsive.isTablet(context) ? 2 : 4),
                    showFinancials: canReports,
                    showExpenses: canExpenses,
                  ),
                  loading: () => const _KpiGridSkeleton(),
                  error: (e, _) => Text(userFriendlyError(e, l10n: l10n)),
                ),
              ),
            ),
          SliverPadding(
            padding: AppSpacing.only(top: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: _QuickActionsRow(
                showPos: canPos,
                showProducts: canProducts,
                showReports: canReports,
                showPurchases: canPurchases,
                onPos: () => context.go('/pos'),
                onProducts: () => context.go('/products'),
                onReports: () => context.go('/reports'),
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.only(top: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _SalesTrendCard(trend: trend),
                        ),
                        AppSpacing.gapMd(),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _LowStockCard(lowStock: lowStock, currency: currency),
                              AppSpacing.gapMd(),
                              _RecentSalesCard(
                                recentSales: recentSales,
                                currency: currency,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _SalesTrendCard(trend: trend),
                        AppSpacing.gapMd(),
                        _LowStockCard(lowStock: lowStock, currency: currency),
                        AppSpacing.gapMd(),
                        _RecentSalesCard(
                          recentSales: recentSales,
                          currency: currency,
                        ),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(child: AppSpacing.gapLg()),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.storeName,
    required this.dateLabel,
    required this.todaySales,
    required this.onOpenPos,
  });

  final String storeName;
  final String dateLabel;
  final String todaySales;
  final VoidCallback? onOpenPos;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;
    return BrandHeroBanner(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                AppSpacing.gapXs(),
                Text(
                  storeName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                AppSpacing.gapXxs(),
                Text(
                  l10n.dashboardTodaySalesDot(todaySales),
                  style: TextStyle(
                    color: brand.teal.withValues(alpha: 0.95),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onOpenPos != null) ...[
            AppSpacing.gapMd(),
            FilledButton.icon(
              onPressed: onOpenPos,
              style: FilledButton.styleFrom(
                backgroundColor: brand.actionBackground,
                foregroundColor: brand.onAction,
                padding: AppSpacing.button,
                minimumSize: const Size(0, 48),
              ),
              icon: const Icon(Icons.point_of_sale, size: AppIcons.md),
              label: Text(l10n.dashboardOpenPos),
            ),
          ],
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpis,
    required this.currency,
    required this.crossAxisCount,
    required this.showFinancials,
    required this.showExpenses,
  });

  final DashboardKpis kpis;
  final String currency;
  final int crossAxisCount;
  final bool showFinancials;
  final bool showExpenses;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_KpiData>[
      if (showFinancials)
        _KpiData(l10n.dashboardMonthlySales, kpis.monthSalesCents, Icons.trending_up, null),
      if (showFinancials)
        _KpiData(
          l10n.dashboardMonthProfit,
          kpis.monthProfitCents,
          Icons.savings_outlined,
          kpis.monthProfitCents >= 0 ? AppColors.accent : AppColors.error,
          kpis.monthProfitCents >= 0 ? AppStatusType.success : AppStatusType.error,
        ),
      if (showExpenses)
        _KpiData(
          l10n.dashboardTodayExpenses,
          kpis.todayExpensesCents,
          Icons.receipt_long_outlined,
          null,
        ),
      if (showExpenses)
        _KpiData(
          l10n.dashboardMonthlyExpenses,
          kpis.monthExpensesCents,
          Icons.payments_outlined,
          null,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AppMetricCard(
          title: item.label,
          value: formatMoney(item.cents, currency: currency),
          icon: item.icon,
          status: item.status,
          valueColor: item.valueColor,
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData(
    this.label,
    this.cents,
    this.icon,
    this.valueColor, [
    this.status = AppStatusType.neutral,
  ]);
  final String label;
  final int cents;
  final IconData icon;
  final Color? valueColor;
  final AppStatusType status;
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.showPos,
    required this.showProducts,
    required this.showReports,
    required this.showPurchases,
    required this.onPos,
    required this.onProducts,
    required this.onReports,
  });

  final bool showPos;
  final bool showProducts;
  final bool showReports;
  final bool showPurchases;
  final VoidCallback onPos;
  final VoidCallback onProducts;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (showPos)
          _ActionChip(
            icon: Icons.point_of_sale,
            label: l10n.navPos,
            onTap: onPos,
            filled: true,
          ),
        if (showProducts)
          _ActionChip(
            icon: Icons.inventory_2_outlined,
            label: l10n.navProducts,
            onTap: onProducts,
          ),
        if (showReports)
          _ActionChip(
            icon: Icons.analytics_outlined,
            label: l10n.navReports,
            onTap: onReports,
          ),
        if (showPurchases)
          _ActionChip(
            icon: Icons.add_shopping_cart,
            label: l10n.navAddPurchase,
            onTap: () => context.go('/purchases/add'),
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: AppIcons.sm),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: AppIcons.sm),
      label: Text(label),
    );
  }
}

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard({required this.trend});

  final AsyncValue<List<DailySalesPoint>> trend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: l10n.dashboardSalesLast7Days,
            subtitle: l10n.dashboardDailyRevenue,
          ),
          AppSpacing.gapMd(),
          SizedBox(
            height: 200,
            child: trend.when(
              skipLoadingOnReload: true,
              data: (points) {
                if (points.every((p) => p.amount == 0)) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bar_chart, size: 40, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(l10n.dashboardNoSalesYet),
                      ],
                    ),
                  );
                }
                return SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
                  primaryYAxis: const NumericAxis(
                    majorGridLines: MajorGridLines(width: 0.5),
                    axisLine: AxisLine(width: 0),
                  ),
                  series: <CartesianSeries<DailySalesPoint, String>>[
                    ColumnSeries<DailySalesPoint, String>(
                      dataSource: points,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.amount,
                      color: AppCharts.sales(Theme.of(context).brightness),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      width: 0.5,
                    ),
                  ],
                  tooltipBehavior: kIsWeb
                      ? null
                      : TooltipBehavior(enable: true),
                );
              },
              loading: () => const SkeletonBox(
                width: double.infinity,
                height: 200,
                borderRadius: 14,
              ),
              error: (e, _) => Center(
                child: Text(l10n.dashboardChartError(e.toString())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.lowStock, required this.currency});

  final AsyncValue<List<Product>> lowStock;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardLowStock,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/products'),
                child: Text(l10n.commonViewAll),
              ),
            ],
          ),
          lowStock.when(
            skipLoadingOnReload: true,
            data: (rows) {
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: context.brand.teal,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.dashboardAllStockGood,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final p in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        child: Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error, size: 18),
                      ),
                      title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        l10n.dashboardQtyAlert(p.quantity, p.minStockAlert ?? 0),
                      ),
                      trailing: Text(formatMoney(p.sellingPriceCents, currency: currency)),
                    ),
                ],
              );
            },
            loading: () => const ListPageSkeleton(itemCount: 3, showHeader: false),
            error: (e, _) => Text(l10n.commonErrorWithDetail(e.toString())),
          ),
        ],
      ),
    );
  }
}

class _RecentSalesCard extends StatelessWidget {
  const _RecentSalesCard({required this.recentSales, required this.currency});

  final AsyncValue<List<Sale>> recentSales;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeFmt = DateFormat.jm(Localizations.localeOf(context).languageCode);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardRecentSales,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/reports'),
                child: Text(l10n.navReports),
              ),
            ],
          ),
          recentSales.when(
            skipLoadingOnReload: true,
            data: (rows) {
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.dashboardNoSalesRecorded),
                );
              }
              return Column(
                children: [
                  for (final s in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.receipt, size: 18),
                      ),
                      title: Text(
                        formatMoney(s.totalCents, currency: currency),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(timeFmt.format(s.createdAt)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => context.go('/reports'),
                    ),
                ],
              );
            },
            loading: () => const ListPageSkeleton(itemCount: 3, showHeader: false),
            error: (e, _) => Text(l10n.commonErrorWithDetail(e.toString())),
          ),
        ],
      ),
    );
  }
}

class _DebtAlertsBanner extends StatelessWidget {
  const _DebtAlertsBanner({
    required this.alerts,
    required this.onViewDebts,
  });

  final DashboardDebtAlerts alerts;
  final VoidCallback onViewDebts;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (alerts.overdueCount > 0) {
      items.add(_AlertChip(
        color: Colors.red.shade700,
        icon: Icons.warning_amber_rounded,
        label:
            '${alerts.overdueCount} customer${alerts.overdueCount == 1 ? '' : 's'} have overdue debts',
      ));
    }
    if (alerts.dueTodayCount > 0) {
      items.add(_AlertChip(
        color: Colors.orange.shade800,
        icon: Icons.today_outlined,
        label:
            '${alerts.dueTodayCount} debt${alerts.dueTodayCount == 1 ? '' : 's'} due today',
      ));
    }
    if (alerts.upcomingCount > 0) {
      items.add(_AlertChip(
        color: Colors.amber.shade900,
        icon: Icons.schedule_outlined,
        label:
            '${alerts.upcomingCount} debt${alerts.upcomingCount == 1 ? '' : 's'} due this week',
      ));
    }

    return Material(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onViewDebts,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Debt alerts',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade900,
                        ),
                  ),
                  const Spacer(),
                  TextButton(onPressed: onViewDebts, child: const Text('View')),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: items),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiGridSkeleton extends StatelessWidget {
  const _KpiGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 1200 ? 4 : (c.maxWidth >= 700 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cols == 1 ? 2.8 : 1.6,
          ),
          itemCount: cols == 1 ? 2 : 4,
          itemBuilder: (_, __) => const SkeletonBox(
            width: double.infinity,
            height: 88,
            borderRadius: 12,
          ),
        );
      },
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

