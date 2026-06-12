import 'package:flutter/material.dart';

import 'responsive.dart';

/// Two-column form on desktop/tablet, single column on mobile.
class ResponsiveFormLayout extends StatelessWidget {
  const ResponsiveFormLayout({
    super.key,
    required this.fields,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> fields;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Responsive.formColumns(context);
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                fields[i],
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < fields.length; i += 2) {
          if (i > 0) rows.add(SizedBox(height: runSpacing));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: fields[i]),
                SizedBox(width: spacing),
                Expanded(
                  child: i + 1 < fields.length
                      ? fields[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
