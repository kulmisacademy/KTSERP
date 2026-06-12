import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../services/accounting_pdf_service.dart';
import 'accounting_export_actions.dart';
import 'accounting_ui.dart';

/// Report page header with summary banner and prominent export action.
class AccountingReportScaffold extends ConsumerWidget {
  const AccountingReportScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.exportFilename,
    required this.buildPdf,
    required this.statusOk,
    required this.statusTitle,
    required this.statusSubtitle,
    required this.children,
    this.metrics = const [],
  });

  final String title;
  final String subtitle;
  final String exportFilename;
  final Future<List<int>> Function(AccountingPdfService service) buildPdf;
  final bool statusOk;
  final String statusTitle;
  final String statusSubtitle;
  final List<Widget> children;
  final List<AccountingReportMetric> metrics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AccountingPageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AccountingPageHeader(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
              AccountingExportButton(
                filename: exportFilename,
                buildPdf: buildPdf,
                showLabel: !Responsive.isMobile(context),
              ),
            ],
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final mobile = Responsive.isMobile(context);
                if (mobile) {
                  return Column(
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        metrics[i],
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: metrics[i]),
                    ],
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          AccountingStatusBanner(
            ok: statusOk,
            title: statusTitle,
            subtitle: statusSubtitle,
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class AccountingReportMetric extends StatelessWidget {
  const AccountingReportMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AccountingSurfaceCard(
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
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
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

/// Trial balance / ledger table with mobile card fallback.
class AccountingReportTable extends StatelessWidget {
  const AccountingReportTable({
    super.key,
    required this.columns,
    required this.rows,
    this.highlightLastRow = false,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final bool highlightLastRow;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AccountingSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < columns.length && c < rows[i].length; c++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                columns[c],
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                rows[i][c],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: c == columns.length - 1
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return AccountingDataTableCard(columns: columns, rows: rows);
  }
}
