import 'package:flutter/material.dart';

import '../../../../ui/widgets/platform_brand_logo.dart';
import '../theme/kulmis_auth_theme.dart';

/// Center-divider logo badge (reference bridge element).
class AuthFloatingLogo extends StatelessWidget {
  const AuthFloatingLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: KulmisAuthTheme.navy.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: PlatformBrandLogo(
          size: size * 0.62,
          style: BrandLogoStyle.original,
        ),
      ),
    );
  }
}
