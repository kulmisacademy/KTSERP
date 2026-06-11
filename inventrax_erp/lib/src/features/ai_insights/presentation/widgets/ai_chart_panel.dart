import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/ai_models.dart';

class AiChartPanel extends StatelessWidget {
  const AiChartPanel({
    super.key,
    required this.snapshot,
    required this.hints,
  });

  final AiBusinessSnapshot snapshot;
  final List<AiChartHint> hints;

  @override
  Widget build(BuildContext context) {
    final charts = hints.isEmpty ? _defaultHints() : hints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final hint in charts.take(3)) ...[
          Text(
            hint.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (hint.subtitle != null)
            Text(hint.subtitle!, style: Theme.of(context).textTheme.bodySmall),
          AppSpacing.gapSm(),
          SizedBox(height: 200, child: _buildChart(context, hint.kind)),
          AppSpacing.gapLg(),
        ],
      ],
    );
  }

  List<AiChartHint> _defaultHints() => const [
        AiChartHint(kind: AiChartKind.revenueTrend, title: '7-day sales'),
        AiChartHint(kind: AiChartKind.expenseComparison, title: 'Expenses by category'),
      ];

  Widget _buildChart(BuildContext context, AiChartKind kind) {
    final brightness = Theme.of(context).brightness;
    switch (kind) {
      case AiChartKind.revenueTrend:
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          series: [
            SplineAreaSeries<AiTrendPoint, String>(
              dataSource: snapshot.salesTrend7d,
              xValueMapper: (p, _) => p.label,
              yValueMapper: (p, _) => p.cents / 100.0,
              color: AppCharts.fill(brightness),
              borderColor: AppCharts.sales(brightness),
              borderWidth: 2,
            ),
          ],
        );
      case AiChartKind.expenseComparison:
        if (snapshot.expensesByCategory.isEmpty) {
          return const Center(child: Text('No expense categories this month'));
        }
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          series: [
            ColumnSeries<AiExpenseCategory, String>(
              dataSource: snapshot.expensesByCategory,
              xValueMapper: (e, _) => e.category.length > 12
                  ? '${e.category.substring(0, 12)}…'
                  : e.category,
              yValueMapper: (e, _) => e.cents / 100.0,
              color: AppCharts.expenses(),
            ),
          ],
        );
      case AiChartKind.productPerformance:
        if (snapshot.topProducts.isEmpty) {
          return const Center(child: Text('No product sales data'));
        }
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          series: [
            ColumnSeries<AiProductRank, String>(
              dataSource: snapshot.topProducts,
              xValueMapper: (p, _) =>
                  p.name.length > 10 ? '${p.name.substring(0, 10)}…' : p.name,
              yValueMapper: (p, _) => p.quantity.toDouble(),
              color: AppCharts.sales(brightness),
            ),
          ],
        );
      case AiChartKind.inventory:
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          series: [
            ColumnSeries<_InvBar, String>(
              dataSource: [
                _InvBar('In stock', snapshot.productCount - snapshot.outOfStockCount),
                _InvBar('Low stock', snapshot.lowStockCount),
                _InvBar('Out of stock', snapshot.outOfStockCount),
              ],
              xValueMapper: (b, _) => b.label,
              yValueMapper: (b, _) => b.value.toDouble(),
              color: AppCharts.inventory(brightness),
            ),
          ],
        );
      case AiChartKind.profitTrend:
        return SfCartesianChart(
          primaryXAxis: const CategoryAxis(),
          legend: const Legend(isVisible: true, position: LegendPosition.bottom),
          series: [
            ColumnSeries<AiTrendPoint, String>(
              name: 'Sales',
              dataSource: snapshot.salesTrend7d,
              xValueMapper: (p, _) => p.label,
              yValueMapper: (p, _) => p.cents / 100.0,
              color: AppCharts.structural(brightness),
            ),
          ],
        );
      case AiChartKind.unknown:
        return const Center(child: Text('Chart not available'));
    }
  }
}

class _InvBar {
  const _InvBar(this.label, this.value);
  final String label;
  final int value;
}
