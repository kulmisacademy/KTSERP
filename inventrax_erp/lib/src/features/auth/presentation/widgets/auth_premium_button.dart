import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/kulmis_auth_theme.dart';

class AuthPremiumButton extends StatefulWidget {
  const AuthPremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  State<AuthPremiumButton> createState() => _AuthPremiumButtonState();
}

class _AuthPremiumButtonState extends State<AuthPremiumButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;

    final hovered = kIsWeb ? false : _hovered;
    final shell = Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: enabled ? KulmisAuthTheme.buttonGradient : null,
        color: enabled ? null : KulmisAuthTheme.teal.withValues(alpha: 0.45),
        boxShadow: enabled && hovered
            ? [
                BoxShadow(
                  color: KulmisAuthTheme.teal.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : enabled
                ? [
                    BoxShadow(
                      color: KulmisAuthTheme.teal.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: kIsWeb ? NoSplash.splashFactory : null,
          hoverColor: Colors.transparent,
          onTap: enabled ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (kIsWeb) return shell;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: shell,
      ),
    );
  }
}
