import 'package:flutter/material.dart';

import 'premium_auth_scaffold.dart';

/// Legacy wrapper — delegates to [PremiumAuthScaffold].
@Deprecated('Use PremiumAuthScaffold directly')
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBrandPanel = true,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBrandPanel;

  @override
  Widget build(BuildContext context) {
    return PremiumAuthScaffold(
      showBrandPanel: showBrandPanel,
      child: child,
    );
  }
}
