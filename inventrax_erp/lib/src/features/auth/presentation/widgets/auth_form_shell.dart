import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/kulmis_auth_theme.dart';
import 'auth_language_menu.dart';

/// Right-side white form panel — stable scroll, language menu isolated.
class AuthFormShell extends ConsumerWidget {
  const AuthFormShell({
    super.key,
    required this.child,
    this.showLanguageMenu = true,
    this.fillHeight = false,
  });

  final Widget child;
  final bool showLanguageMenu;
  final bool fillHeight;

  static const _padding = EdgeInsets.fromLTRB(32, 72, 32, 40);
  static const _maxWidth = 440.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColoredBox(
      color: KulmisAuthTheme.formBg,
      child: SafeArea(
        child: Stack(
          children: [
            if (showLanguageMenu)
              const Positioned(
                top: 16,
                right: 24,
                child: AuthLanguageMenu(),
              ),
            if (fillHeight)
              Positioned.fill(
                child: Padding(
                  padding: _padding,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: _maxWidth,
                          height: constraints.maxHeight,
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Center(
                child: SingleChildScrollView(
                  padding: _padding,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: child,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
