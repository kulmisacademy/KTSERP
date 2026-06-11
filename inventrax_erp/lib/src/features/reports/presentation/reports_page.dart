import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app/app_theme.dart';
import '../../../core/design/design_system.dart';
import '../../../core/media/branded_pdf_header.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/store/active_store_scope.dart';
import '../../../core/store_context.dart';
import '../../users/domain/app_permission.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../data/local/store_settings_provider.dart';
import '../../../ui/components/app_card.dart';
import '../../../core/ux/user_friendly_error.dart';
import '../../../ui/components/app_skeleton.dart';
import '../../../ui/layout/app_shell.dart';
import '../domain/report_models.dart';
import '../services/pdf_report_service.dart';

final _rangeProvider = NotifierProvider<_ReportRange, DateTimeRange>(
  _ReportRange.new,
);

class _ReportRange extends Notifier<DateTimeRange> {
  @override
  DateTimeRange build() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));
  }

  void set(DateTimeRange r) => state = r;
}

final reportDataProvider = FutureProvider.autoDispose<_ReportData>((ref) async {
  final scope = ref.watch(activeStoreScopeProvider);
  final db = ref.watch(appDatabaseProvider);
  final tenantId = scope.tenantId;
  final storeId = scope.storeId;
  final r = ref.watch(_rangeProvider);

  final sales = await db.listSales(storeId: storeId, from: r.start, to: r.end);
  final salesTotal = await db.sumSalesTotalCents(
    tenantId: tenantId,
    storeId: storeId,
    from: r.start,
    to: r.end,
  );
  final expensesTotal = await db.sumExpensesCents(
    tenantId: tenantId,
    storeId: storeId,
    from: r.start,
    to: r.end,
  );
  final cogsTotal = await db.sumCogsCents(
    tenantId: tenantId,
    storeId: storeId,
    from: r.start,
    to: r.end,
  );

  // Daily points for charts (capped for performance).
  final days = r.end.difference(r.start).inDays;
  final maxDays = 90;
  final effectiveEnd = days > maxDays ? r.start.add(Duration(days: maxDays)) : r.end;
  final points = <_DailyPoint>[];
  for (var i = 0; i < effectiveEnd.difference(r.start).inDays; i++) {
    final day = DateTime(r.start.year, r.start.month, r.start.day).add(Duration(days: i));
    final next = day.add(const Duration(days: 1));
    final s = await db.sumSalesTotalCents(
      tenantId: tenantId,
      storeId: storeId,
      from: day,
      to: next,
    );
    final e = await db.sumExpensesCents(
      tenantId: tenantId,
      storeId: storeId,
      from: day,
      to: next,
    );
    final c = await db.sumCogsCents(
      tenantId: tenantId,
      storeId: storeId,
      from: day,
      to: next,
    );
    points.add(_DailyPoint(day: day, salesCents: s, expensesCents: e, cogsCents: c));
  }

  final saleItems = await db.listSaleItemsForSales(
    storeId: storeId,
    saleIds: sales.map((s) => s.id).toList(growable: false),
  );
  final itemsBySaleId = <String, List<SaleItem>>{};
  for (final it in saleItems) {
    (itemsBySaleId[it.saleId] ??= []).add(it);
  }

  return _ReportData(
    range: r,
    sales: sales,
    itemsBySaleId: itemsBySaleId,
    daily: points,
    profit: ProfitSnapshot(
      salesCents: salesTotal,
      cogsCents: cogsTotal,
      expensesCents: expensesTotal,
    ),
  );
});

class _ReportData {
  const _ReportData({
    required this.range,
    required this.sales,
    required this.itemsBySaleId,
    required this.daily,
    required this.profit,
  });

  final DateTimeRange range;
  final List<Sale> sales;
  final Map<String, List<SaleItem>> itemsBySaleId;
  final List<_DailyPoint> daily;
  final ProfitSnapshot profit;
}

class _DailyPoint {
  const _DailyPoint({
    required this.day,
    required this.salesCents,
    required this.expensesCents,
    required this.cogsCents,
  });

  final DateTime day;
  final int salesCents;
  final int expensesCents;
  final int cogsCents;
  int get profitCents => salesCents - expensesCents - cogsCents;
}

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(reportDataProvider);
    final range = ref.watch(_rangeProvider);
    final settings = ref.watch(storeSettingsProvider);
    final currency = settings.value?.currencyCode ?? 'USD';
    final dateLabel = DateFormat('MMM d, yyyy');

    final l10n = context.l10n;
    return AppShell(
      route: '/reports',
      actions: [
        if (StoreContext.can(AppPermission.aiInsightsView))
          FilledButton.tonalIcon(
            onPressed: () => context.go('/ai-insights'),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l10n.navAiInsights),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.brand.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: AppCharts.structural(Theme.of(context).brightness),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reportsRangeLabel,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateLabel.format(range.start)} → ${dateLabel.format(range.end)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: range,
                      );
                      if (picked != null) {
                        ref.read(_rangeProvider.notifier).set(picked);
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(l10n.reportsPickDateRange),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: data.when(
              data: (d) => _ReportBody(data: d, currency: currency),
              loading: () => const ReportsSkeleton(),
              error: (e, _) => Center(child: Text(userFriendlyError(e, l10n: l10n))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({required this.data, required this.currency});

  final _ReportData data;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    String money(int cents) => formatMoney(cents, currency: currency);
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1200 ? 5 : (width >= 820 ? 3 : 2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          l10n.reportsSummary,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cols >= 3 ? 2.2 : 2.5,
          children: [
            _kpiTile(
              context,
              label: l10n.reportsRevenue,
              value: money(data.profit.salesCents),
              icon: Icons.trending_up_rounded,
              color: AppCharts.sales(Theme.of(context).brightness),
            ),
            _kpiTile(
              context,
              label: l10n.reportsCogs,
              value: money(data.profit.cogsCents),
              icon: Icons.inventory_2_outlined,
              color: AppCharts.structural(Theme.of(context).brightness),
            ),
            _kpiTile(
              context,
              label: l10n.reportsExpenses,
              value: money(data.profit.expensesCents),
              icon: Icons.receipt_long_outlined,
              color: AppCharts.expenses(),
            ),
            _kpiTile(
              context,
              label: l10n.reportsNetProfit,
              value: money(data.profit.profitCents),
              icon: Icons.savings_outlined,
              color: data.profit.profitCents >= 0
                  ? InventraXTheme.accent
                  : const Color(0xFFE53935),
            ),
            _kpiTile(
              context,
              label: l10n.reportsSalesCount,
              value: '${data.sales.length}',
              icon: Icons.receipt_outlined,
              color: AppCharts.structural(Theme.of(context).brightness),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _exportRow(context, ref),
        const SizedBox(height: 18),
        _charts(context),
        const SizedBox(height: 24),
        Text(
          l10n.navSales,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        ...data.sales.map(
          (s) {
            final items = data.itemsBySaleId[s.id] ?? const <SaleItem>[];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: Text(
                    money(s.totalCents),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd().add_jm().format(s.createdAt)} • ${l10n.reportsSaleItems(items.length, s.id.substring(0, 8))}',
                  ),
                  children: [
                    for (final it in items)
                      ListTile(
                        dense: true,
                        title: Text(it.name),
                        subtitle: Text(
                          l10n.reportsLineItemDetail(
                            it.quantity,
                            money(it.unitPriceCents),
                            money(it.unitCostCents),
                          ),
                        ),
                        trailing: Text(money(it.lineTotalCents)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _exportRow(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final settings = ref.read(storeSettingsProvider).value;
                final branding = await StoreBrandingPdf.fromSettings(settings);
                final service = PdfReportService();
                final pdf = service.buildDailyReportPdf(
                  from: data.range.start,
                  to: data.range.end,
                  profit: data.profit,
                  sales: data.sales,
                  branding: branding,
                );
                final bytes = await pdf.save();
                final dir = await getTemporaryDirectory();
                await File('${dir.path}/inventrax_report.pdf')
                    .writeAsBytes(bytes, flush: true);
                if (!context.mounted) return;
                await Printing.sharePdf(
                  bytes: bytes,
                  filename: 'inventrax_report.pdf',
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(l10n.reportsExportPdf),
              style: FilledButton.styleFrom(
                backgroundColor: InventraXTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                String csvEscape(String s) => '"${s.replaceAll('"', '""')}"';
                final lines = <String>[
                  'sale_id,sale_created_at,sale_total,item_name,item_barcode,item_qty,item_unit_price,item_unit_cost,item_line_total',
                ];
                for (final s in data.sales) {
                  final items = data.itemsBySaleId[s.id] ?? const <SaleItem>[];
                  if (items.isEmpty) {
                    lines.add(
                      '${csvEscape(s.id)},${csvEscape(s.createdAt.toIso8601String())},${s.totalCents},,,,,,,',
                    );
                    continue;
                  }
                  for (final it in items) {
                    lines.add(
                      [
                        csvEscape(s.id),
                        csvEscape(s.createdAt.toIso8601String()),
                        s.totalCents.toString(),
                        csvEscape(it.name),
                        csvEscape(it.barcode ?? ''),
                        it.quantity.toString(),
                        it.unitPriceCents.toString(),
                        it.unitCostCents.toString(),
                        it.lineTotalCents.toString(),
                      ].join(','),
                    );
                  }
                }
                final bytes = lines.join('\n').codeUnits;
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/inventrax_report.csv');
                await file.writeAsBytes(bytes, flush: true);
                if (!context.mounted) return;
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path, mimeType: 'text/csv')],
                    text: l10n.reportsShareCsvText,
                  ),
                );
              },
              icon: const Icon(Icons.table_view),
              label: Text(l10n.reportsExportCsv),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _charts(BuildContext context) {
    final points = data.daily;
    final labelFmt = DateFormat.Md();
    final chartData = points
        .map(
          (p) => _ChartPoint(
            label: labelFmt.format(p.day),
            sales: p.salesCents / 100,
            expenses: p.expensesCents / 100,
            profit: p.profitCents / 100,
          ),
        )
        .toList(growable: false);

    final hasAny = points.any((p) => p.salesCents != 0 || p.expensesCents != 0);
    if (!hasAny) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 38,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No chart data for this range yet. Complete a few sales/expenses to see trends.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 280,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              legend: const Legend(isVisible: true),
              primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
              tooltipBehavior: kIsWeb
                  ? null
                  : TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                LineSeries<_ChartPoint, String>(
                  name: 'Sales',
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.sales,
                  color: AppCharts.sales(Theme.of(context).brightness),
                  width: 2.4,
                  markerSettings: const MarkerSettings(isVisible: true, width: 4, height: 4),
                ),
                LineSeries<_ChartPoint, String>(
                  name: 'Expenses',
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.expenses,
                  color: AppCharts.expenses(),
                  width: 2.4,
                  markerSettings: const MarkerSettings(isVisible: true, width: 4, height: 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 260,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              legend: const Legend(isVisible: true),
              primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
              tooltipBehavior: kIsWeb
                  ? null
                  : TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<_ChartPoint, String>(
                  name: 'Profit',
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.profit,
                  color: AppCharts.structural(Theme.of(context).brightness),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpiTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
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

class _ChartPoint {
  const _ChartPoint({
    required this.label,
    required this.sales,
    required this.expenses,
    required this.profit,
  });

  final String label;
  final double sales;
  final double expenses;
  final double profit;
}

