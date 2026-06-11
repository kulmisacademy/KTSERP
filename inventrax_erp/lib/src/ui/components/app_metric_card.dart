import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';
import 'app_card.dart';

/// Executive metric tile — dashboard, health, reports.
class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.status = AppStatusType.neutral,
    this.valueColor,
    this.onTap,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final AppStatusType status;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accent = AppStatus.color(status, brightness: brightness);
    final iconBg = AppStatus.container(status, brightness: brightness);

    return AppCard(
      onTap: onTap,
      padding: AppSpacing.card,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(icon, color: accent, size: AppIcons.lg),
            ),
            AppSpacing.gapMd(),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTypography.metricLabel(context)),
                AppSpacing.gapXxs(),
                Text(
                  value,
                  style: AppTypography.metricValue(context).copyWith(
                    color: valueColor ?? accent,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.gapXxs(),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
