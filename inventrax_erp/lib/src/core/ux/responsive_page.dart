import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'responsive.dart';

/// Standard page body: SafeArea, responsive padding, optional scroll + max width.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.scroll = false,
    this.padding = true,
    this.safeArea = true,
    this.maxContentWidth = 1400,
    this.bottomInsetForKeyboard = false,
  });

  final Widget child;
  final bool scroll;
  final bool padding;
  final bool safeArea;
  final double maxContentWidth;
  final bool bottomInsetForKeyboard;

  @override
  Widget build(BuildContext context) {
    Widget body = child;

    if (padding) {
      body = Padding(
        padding: Responsive.pagePadding(context),
        child: body,
      );
    }

    if (scroll) {
      body = SingleChildScrollView(
        child: body,
      );
    }

    if (Responsive.isDesktop(context) && maxContentWidth > 0) {
      body = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: body,
        ),
      );
    }

    if (bottomInsetForKeyboard) {
      body = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: body,
      );
    }

    if (safeArea) {
      body = SafeArea(child: body);
    }

    return body;
  }
}

/// Mobile AppBar back when the route stack allows pop.
Widget? responsiveMobileBackLeading(BuildContext context) {
  if (!Responsive.isMobile(context)) return null;
  if (!context.canPop()) return null;
  return IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.pop(),
  );
}
