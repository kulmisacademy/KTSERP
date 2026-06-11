import 'package:flutter/material.dart';

/// Lightweight motion system — subtle, fast, enterprise-appropriate.
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;

  static Animation<double> fadeIn(Animation<double> parent) =>
      CurvedAnimation(parent: parent, curve: enter);

  static Animation<Offset> slideUp(Animation<double> parent) =>
      Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: parent, curve: standard));
}
