import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

/// Consistent navy→teal hero banner used on dashboard, AI, accounting, etc.
class BrandHeroBanner extends StatelessWidget {
  const BrandHeroBanner({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardLg,
    this.showAccentLine = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool showAccentLine;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: brand.heroGradient,
        boxShadow: AppShadows.elevated(brightness),
      ),
      child: Stack(
        children: [
          if (showAccentLine)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      brand.heroAccentLine,
                      brand.teal.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
