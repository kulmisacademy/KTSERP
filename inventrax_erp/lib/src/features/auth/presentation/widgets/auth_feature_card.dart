import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/kulmis_auth_theme.dart';

class AuthFeatureCardData {
  const AuthFeatureCardData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Glassmorphism feature tile — hover only rebuilds this card.
class AuthFeatureCard extends StatefulWidget {
  const AuthFeatureCard({super.key, required this.data});

  final AuthFeatureCardData data;

  @override
  State<AuthFeatureCard> createState() => _AuthFeatureCardState();
}

class _AuthFeatureCardState extends State<AuthFeatureCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hovered = kIsWeb ? false : _hovered;
    final card = Container(
      margin: EdgeInsets.only(bottom: hovered ? 2 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hovered
              ? KulmisAuthTheme.teal.withValues(alpha: 0.35)
              : KulmisAuthTheme.glassBorder,
        ),
        boxShadow: hovered
            ? [
                BoxShadow(
                  color: KulmisAuthTheme.teal.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: hovered
                  ? const Color(0x22FFFFFF)
                  : KulmisAuthTheme.glassFill,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KulmisAuthTheme.teal.withValues(alpha: 0.16),
                    border: Border.all(
                      color: KulmisAuthTheme.teal.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: KulmisAuthTheme.teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data.description,
                        style: GoogleFonts.inter(
                          color: KulmisAuthTheme.textSoftOnDark,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (kIsWeb) return card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: card,
      ),
    );
  }
}
