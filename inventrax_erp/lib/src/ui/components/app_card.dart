import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';
import '../../core/ux/web_interaction.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final decoration = BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: AppRadius.lgAll,
      border: Border.all(
        color: AppColors.border(brightness).withValues(alpha: 0.85),
      ),
      boxShadow: elevated
          ? AppShadows.elevated(brightness)
          : AppShadows.card(brightness),
    );

    final card = kIsWeb
        ? Container(decoration: decoration, child: Padding(padding: padding, child: child))
        : AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.standard,
            decoration: decoration,
            child: Padding(padding: padding, child: child),
          );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: WebInteraction.tap(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: card,
      ),
    );
  }
}
