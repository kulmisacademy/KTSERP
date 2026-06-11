import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventrax_erp/l10n/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app/app_theme.dart';
import '../../../core/design/design_system.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/nav_l10n.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../data/accounting_provider.dart';
import '../../../ui/widgets/brand_hero_banner.dart';
import 'accounting_shell.dart';
import 'widgets/accounting_kpi_card.dart';

final _acctKpisProvider = FutureProvider.autoDispose<AccountingDashboardKpis>(
  (ref) async {
    ref.watch(accountingInitProvider);
    final db = ref.watch(appDatabaseProvider);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return db.accountingDashboardKpis(
      storeId: StoreContext.storeId,
      from: start,
      to: end,
    );
  },
);

final _monthlyTrendProvider =
    FutureProvider.autoDispose<List<MonthlyAmountPoint>>((ref) async {
  ref.watch(accountingInitProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.monthlyRevenueExpense(
    storeId: StoreContext.storeId,
    months: 6,
  );
});

class AccountingDashboardPage extends ConsumerWidget {
  const AccountingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(storeCurrencyProvider);
    final kpis = ref.watch(_acctKpisProvider);
    final trend = ref.watch(_monthlyTrendProvider);
    final monthLabel = DateFormat.yMMMM().format(DateTime.now());

    final l10n = context.l10n;
    return AccountingShell(
      title: localizedNavLabel(l10n, '/accounting'),
      child: kpis.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e.toString()))),
        data: (k) {
          final width = MediaQuery.sizeOf(context).width;
          final cols = width >= 1280 ? 3 : (width >= 720 ? 2 : 1);
          final isWide = width >= 1000;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _FinanceHeroBanner(
                    l10n: l10n,
                    monthLabel: monthLabel,
                    netProfit: formatMoney(k.netProfitCents, currency: currency),
                    revenue: formatMoney(k.revenueCents, currency: currency),
                    isPositive: k.netProfitCents >= 0,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _QuickReportRow(
                    l10n: l10n,
                    onTrialBalance: () =>
                        context.go('/accounting/reports/trial-balance'),
                    onProfitLoss: () =>
                        context.go('/accounting/reports/profit-loss'),
                    onBalanceSheet: () =>
                        context.go('/accounting/reports/balance-sheet'),
                    onJournals: () => context.go('/accounting/journals'),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.acctMonthToDate,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 88,
                  ),
                  delegate: SliverChildListDelegate([
                    AccountingKpiCard(
                      label: l10n.acctRevenueLabel,
                      value: formatMoney(k.revenueCents, currency: currency),
                      icon: Icons.trending_up_rounded,
                      accent: InventraXTheme.accent,
                      subtitle: monthLabel,
                    ),
                    AccountingKpiCard(
                      label: l10n.acctNetProfit,
                      value: formatMoney(k.netProfitCents, currency: currency),
                      icon: Icons.savings_outlined,
                      accent: k.netProfitCents >= 0
                          ? InventraXTheme.accent
                          : const Color(0xFFE53935),
                      subtitle: l10n.acctAfterCogsExpenses,
                    ),
                    AccountingKpiCard(
                      label: l10n.acctExpensesLabel,
                      value: formatMoney(k.expenseCents, currency: currency),
                      icon: Icons.receipt_long_outlined,
                      accent: const Color(0xFFFFA000),
                      subtitle: monthLabel,
                    ),
                    AccountingKpiCard(
                      label: l10n.acctCashWallets,
                      value: formatMoney(k.cashCents, currency: currency),
                      icon: Icons.account_balance_wallet_outlined,
                      subtitle: l10n.acctAllPaymentAccounts,
                      onTap: () => context.go('/accounting/payment-accounts'),
                    ),
                    AccountingKpiCard(
                      label: l10n.acctReceivable,
                      value: formatMoney(k.receivableCents, currency: currency),
                      icon: Icons.call_received_rounded,
                      subtitle: l10n.acctCustomerCredit,
                    ),
                    AccountingKpiCard(
                      label: l10n.acctPayable,
                      value: formatMoney(k.payableCents, currency: currency),
                      icon: Icons.call_made_rounded,
                      subtitle: l10n.acctSupplierBalances,
                      onTap: () => context.go('/accounting/cash'),
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _RevenueExpenseChart(
                                l10n: l10n,
                                trend: trend,
                                currency: currency,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _BooksStatusCard(
                                l10n: l10n,
                                kpis: k,
                                currency: currency,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _RevenueExpenseChart(
                              l10n: l10n,
                              trend: trend,
                              currency: currency,
                            ),
                            const SizedBox(height: 16),
                            _BooksStatusCard(
                              l10n: l10n,
                              kpis: k,
                              currency: currency,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FinanceHeroBanner extends StatelessWidget {
  const _FinanceHeroBanner({
    required this.l10n,
    required this.monthLabel,
    required this.netProfit,
    required this.revenue,
    required this.isPositive,
  });

  final AppLocalizations l10n;
  final String monthLabel;
  final String netProfit;
  final String revenue;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return BrandHeroBanner(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.acctFinancialOverview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.acctRevenueLine(revenue),
                  style: TextStyle(
                    color: brand.teal.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.acctNetProfit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                netProfit,
                style: TextStyle(
                  color: isPositive ? brand.teal : AppColors.error,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickReportRow extends StatelessWidget {
  const _QuickReportRow({
    required this.l10n,
    required this.onTrialBalance,
    required this.onProfitLoss,
    required this.onBalanceSheet,
    required this.onJournals,
  });

  final AppLocalizations l10n;
  final VoidCallback onTrialBalance;
  final VoidCallback onProfitLoss;
  final VoidCallback onBalanceSheet;
  final VoidCallback onJournals;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ChipLink(
            label: l10n.acctTrialBalance,
            icon: Icons.balance_outlined,
            onTap: onTrialBalance,
          ),
          const SizedBox(width: 8),
          _ChipLink(
            label: l10n.acctProfitLossShort,
            icon: Icons.trending_up,
            onTap: onProfitLoss,
          ),
          const SizedBox(width: 8),
          _ChipLink(
            label: l10n.acctBalanceSheet,
            icon: Icons.table_chart_outlined,
            onTap: onBalanceSheet,
          ),
          const SizedBox(width: 8),
          _ChipLink(
            label: l10n.acctJournals,
            icon: Icons.menu_book_outlined,
            onTap: onJournals,
          ),
        ],
      ),
    );
  }
}

class _ChipLink extends StatelessWidget {
  const _ChipLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: InventraXTheme.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _RevenueExpenseChart extends StatelessWidget {
  const _RevenueExpenseChart({
    required this.l10n,
    required this.trend,
    required this.currency,
  });

  final AppLocalizations l10n;
  final AsyncValue<List<MonthlyAmountPoint>> trend;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.acctRevenueVsExpenses,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                l10n.acctLast6Months,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          trend.when(
            loading: () => const SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 200,
              child: Center(child: Text(l10n.acctChartError(e.toString()))),
            ),
            data: (points) {
              final hasData = points.any(
                (p) => p.revenueCents > 0 || p.expenseCents > 0,
              );
              if (!hasData) {
                return SizedBox(
                  height: 280,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.acctNoActivityYet,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.acctNoActivityHint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final chartData = points
                  .map(
                    (p) => _ChartPoint(
                      _shortMonth(p.label),
                      p.revenueCents / 100,
                      p.expenseCents / 100,
                    ),
                  )
                  .toList();

              return SizedBox(
                height: 280,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.only(top: 8),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compactCurrency(
                      symbol: _currencySymbol(currency),
                    ),
                    majorGridLines: MajorGridLines(
                      width: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  tooltipBehavior: kIsWeb
                      ? null
                      : TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    ColumnSeries<_ChartPoint, String>(
                      name: l10n.acctRevenueLabel,
                      dataSource: chartData,
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.revenue,
                      color: InventraXTheme.accent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      width: 0.55,
                    ),
                    ColumnSeries<_ChartPoint, String>(
                      name: l10n.acctExpensesLabel,
                      dataSource: chartData,
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.expense,
                      color: const Color(0xFFFFA000),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      width: 0.55,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _shortMonth(String label) {
    final parts = label.split('/');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      if (m != null && m >= 1 && m <= 12) {
        return DateFormat.MMM().format(DateTime(2000, m));
      }
    }
    return label;
  }

  String _currencySymbol(String currency) {
    return switch (currency) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      _ => '$currency ',
    };
  }
}

class _BooksStatusCard extends StatelessWidget {
  const _BooksStatusCard({
    required this.l10n,
    required this.kpis,
    required this.currency,
  });

  final AppLocalizations l10n;
  final AccountingDashboardKpis kpis;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatusRow(
        l10n.acctDoubleEntry,
        l10n.acctStatusActive,
        Icons.verified_outlined,
        InventraXTheme.accent,
      ),
      _StatusRow(
        l10n.acctCashPosition,
        formatMoney(kpis.cashCents, currency: currency),
        Icons.account_balance_wallet_outlined,
        InventraXTheme.primary,
      ),
      _StatusRow(
        l10n.acctOutstandingAr,
        formatMoney(kpis.receivableCents, currency: currency),
        Icons.call_received_rounded,
        const Color(0xFF5C6BC0),
      ),
      _StatusRow(
        l10n.acctOutstandingAp,
        formatMoney(kpis.payableCents, currency: currency),
        Icons.call_made_rounded,
        const Color(0xFFFFA000),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.acctBooksAtGlance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPoint {
  const _ChartPoint(this.label, this.revenue, this.expense);
  final String label;
  final double revenue;
  final double expense;
}
