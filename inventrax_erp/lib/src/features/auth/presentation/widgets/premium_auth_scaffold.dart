import 'package:flutter/material.dart';

import '../theme/kulmis_auth_theme.dart';
import 'auth_brand_showcase.dart';
import 'auth_floating_logo.dart';
import 'auth_form_shell.dart';

/// Premium split-screen auth layout (KULMIS ERP reference).
class PremiumAuthScaffold extends StatefulWidget {
  const PremiumAuthScaffold({
    super.key,
    required this.child,
    this.showBrandPanel = true,
    this.showFloatingLogo = true,
    this.showLanguageMenu = true,
    this.fillHeight = false,
  });

  final Widget child;
  final bool showBrandPanel;
  final bool showFloatingLogo;
  final bool showLanguageMenu;
  final bool fillHeight;

  static const _mobileBreakpoint = 720.0;
  static const _tabletBreakpoint = 1100.0;

  @override
  State<PremiumAuthScaffold> createState() => _PremiumAuthScaffoldState();
}

class _PremiumAuthScaffoldState extends State<PremiumAuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KulmisAuthTheme.softBg,
      body: FadeTransition(
        opacity: _fade,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isMobile = w < PremiumAuthScaffold._mobileBreakpoint;
            final isTablet =
                w >= PremiumAuthScaffold._mobileBreakpoint &&
                w < PremiumAuthScaffold._tabletBreakpoint;

            if (isMobile || !widget.showBrandPanel) {
              return _MobileLayout(
                showBrand: widget.showBrandPanel && isMobile,
                showLanguageMenu: widget.showLanguageMenu,
                fillHeight: widget.fillHeight,
                child: widget.child,
              );
            }

            final leftFlex = isTablet ? 44 : 50;
            final rightFlex = 100 - leftFlex;
            final dividerX = w * leftFlex / 100;

            return Stack(
              fit: StackFit.expand,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: leftFlex,
                      child: const AuthBrandShowcase(),
                    ),
                    Expanded(
                      flex: rightFlex,
                      child: AuthFormShell(
                        showLanguageMenu: widget.showLanguageMenu,
                        fillHeight: widget.fillHeight,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
                if (widget.showFloatingLogo)
                  Positioned(
                    left: dividerX - 32,
                    top: constraints.maxHeight / 2 - 32,
                    child: const AuthFloatingLogo(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.showBrand,
    required this.showLanguageMenu,
    required this.fillHeight,
    required this.child,
  });

  final bool showBrand;
  final bool showLanguageMenu;
  final bool fillHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBrand)
          const SizedBox(
            height: 300,
            child: AuthBrandShowcase(compact: true),
          ),
        Expanded(
          child: AuthFormShell(
            showLanguageMenu: showLanguageMenu,
            fillHeight: fillHeight,
            child: child,
          ),
        ),
      ],
    );
  }
}
