import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

/// Enterprise table shell: sticky header, consistent row height, hover.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 640,
    this.rowHeight = 48,
    this.headerHeight = 44,
  });

  final List<AppDataColumn> columns;
  final List<AppDataRow> rows;
  final double minWidth;
  final double rowHeight;
  final double headerHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = AppColors.border(theme.brightness);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: SizedBox(
                      height: headerHeight,
                      child: Row(
                        children: [
                          for (final col in columns)
                            Expanded(
                              flex: col.flex,
                              child: Padding(
                                padding: AppSpacing.listItem,
                                child: Text(
                                  col.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: border),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: border),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: row.onTap,
                            hoverColor: theme.colorScheme.primary.withValues(alpha: 0.04),
                            child: SizedBox(
                              height: rowHeight,
                              child: Row(
                                children: [
                                  for (var i = 0; i < columns.length; i++)
                                    Expanded(
                                      flex: columns[i].flex,
                                      child: Padding(
                                        padding: AppSpacing.listItem,
                                        child: DefaultTextStyle(
                                          style: theme.textTheme.bodyMedium!,
                                          child: row.cells[i],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppDataColumn {
  const AppDataColumn({required this.label, this.flex = 1});
  final String label;
  final int flex;
}

class AppDataRow {
  const AppDataRow({required this.cells, this.onTap});
  final List<Widget> cells;
  final VoidCallback? onTap;
}
