import 'package:flutter/material.dart';



import '../../core/design/design_system.dart';



/// How the platform hexagon logo is framed on different surfaces.

enum BrandLogoStyle {

  /// Original LOGO-02 — no overlays, white background preserved.

  original,

  /// Alias for [original] on auth/marketing surfaces.

  hero,

  /// Sidebar / compact surfaces.

  sidebar,

  /// Inline on light panels.

  inline,

}



/// Platform logo — always renders original LOGO-02.png unchanged.

class PlatformBrandLogo extends StatelessWidget {

  const PlatformBrandLogo({

    super.key,

    this.size = 40,

    this.style = BrandLogoStyle.sidebar,

    @Deprecated('Use style instead') this.onDarkSurface = false,

    @Deprecated('Use style instead') this.showBacking = true,

  });



  final double size;

  final BrandLogoStyle style;

  final bool onDarkSurface;

  final bool showBacking;



  @override

  Widget build(BuildContext context) {

    final brand = context.brand;



    return Image.asset(

      BrandAssets.platformIcon,

      width: size,

      height: size,

      fit: BoxFit.contain,

      filterQuality: FilterQuality.high,

      isAntiAlias: true,

      gaplessPlayback: true,

      errorBuilder: (context, error, stackTrace) => Icon(

        Icons.hexagon_outlined,

        size: size * 0.72,

        color: brand.teal,

      ),

    );

  }

}


