import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';
import 'platform_brand_logo.dart';

/// Left auth hero — logo + title block aligned to LOGO-02 proportions.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({
    super.key,
    this.title,
    this.subtitle,
    this.logoSize = 136,
  });

  final String? title;
  final String? subtitle;
  final double logoSize;

  static const _contentMaxWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final gap = logoSize * 0.2;
    final lineWidth = logoSize * BrandAssets.platformIconAspect * 0.5;

    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlatformBrandLogo(
              size: logoSize,
              style: BrandLogoStyle.original,
            ),
            SizedBox(height: gap),
            Container(
              width: lineWidth,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: brand.teal,
              ),
            ),
            SizedBox(height: gap * 0.75),
            if (title == null) ...[
              Text(
                'InventraX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'ERP',
                style: TextStyle(
                  color: brand.teal,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -0.8,
                ),
              ),
            ] else ...[
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.4,
                ),
              ),
            ],
            SizedBox(height: gap * 0.7),
            Text(
              subtitle ??
                  'Run your store with confidence. Register in minutes or sign in to continue.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
