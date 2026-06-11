import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web-safe ink/hover — avoids MouseTracker assertion loops on Flutter Web.
abstract final class WebInteraction {
  static bool get isWeb => kIsWeb;

  static InteractiveInkFeatureFactory? get splashFactory =>
      kIsWeb ? NoSplash.splashFactory : null;

  static Color? get hoverColor => kIsWeb ? Colors.transparent : null;

  static Color? get highlightColor => kIsWeb ? Colors.transparent : null;

  /// Prefer [GestureDetector] over [InkWell] on web for simple taps.
  static Widget tap({
    required VoidCallback? onTap,
    required Widget child,
    BorderRadius? borderRadius,
  }) {
    if (!kIsWeb || onTap == null) {
      return InkWell(
        splashFactory: splashFactory,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        onTap: onTap,
        borderRadius: borderRadius,
        child: child,
      );
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
