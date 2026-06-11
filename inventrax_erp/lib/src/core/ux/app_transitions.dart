import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_animations.dart';

/// Consistent route transitions (fade / shared-axis style).
abstract final class InventraTransitions {
  static CustomTransitionPage<void> fade({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.normal,
      reverseTransitionDuration: AppAnimations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: AppAnimations.fadeIn(animation),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<void> slideUp({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.normal,
      reverseTransitionDuration: AppAnimations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: AppAnimations.slideUp(animation),
            child: child,
          ),
        );
      },
    );
  }
}
