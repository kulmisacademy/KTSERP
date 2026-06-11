import 'package:flutter/material.dart';

/// 4pt / 8pt spacing scale — use everywhere for visual consistency.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets page = EdgeInsets.all(md);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets cardLg = EdgeInsets.all(lg);
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: sm + 2,
    vertical: sm + 2,
  );
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm + 2,
  );

  static SizedBox gapXxs() => const SizedBox(height: xxs, width: xxs);
  static SizedBox gapXs() => const SizedBox(height: xs, width: xs);
  static SizedBox gapSm() => const SizedBox(height: sm, width: sm);
  static SizedBox gapMd() => const SizedBox(height: md, width: md);
  static SizedBox gapLg() => const SizedBox(height: lg, width: lg);
  static SizedBox gapXl() => const SizedBox(height: xl, width: xl);

  static EdgeInsets only({double top = 0, double right = 0, double bottom = 0, double left = 0}) =>
      EdgeInsets.only(top: top, right: right, bottom: bottom, left: left);
}
