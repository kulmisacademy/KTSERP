import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

enum AppButtonVariant { primary, secondary, tonal, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.sm => 36,
        AppButtonSize.md => 44,
        AppButtonSize.lg => 52,
      };

  @override
  Widget build(BuildContext context) {
    final iconSize = size == AppButtonSize.sm ? AppIcons.sm : AppIcons.md;
    final child = loading
        ? SizedBox(
            width: AppIcons.md,
            height: AppIcons.md,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.secondary
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label),
            ],
          );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(0, _height)),
      padding: WidgetStateProperty.all(AppSpacing.button),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          style: style,
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          style: style,
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          style: style,
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      AppButtonVariant.danger => FilledButton(
          style: style.merge(
            FilledButton.styleFrom(backgroundColor: AppColors.error),
          ),
          onPressed: loading ? null : onPressed,
          child: child,
        ),
    };

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
