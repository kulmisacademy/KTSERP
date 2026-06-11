import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../ui/widgets/platform_brand_logo.dart';
import '../theme/kulmis_auth_theme.dart';
import 'auth_chart_glow.dart';
import 'auth_feature_card.dart';

/// Left branding panel — const structure, l10n only where needed.
class AuthBrandShowcase extends StatelessWidget {
  const AuthBrandShowcase({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logoSize = compact ? 44.0 : 52.0;

    final features = [
      AuthFeatureCardData(
        icon: Icons.shield_outlined,
        title: l10n.authFeatureSecureTitle,
        description: l10n.authFeatureSecureDesc,
      ),
      AuthFeatureCardData(
        icon: Icons.bolt_outlined,
        title: l10n.authFeatureFastTitle,
        description: l10n.authFeatureFastDesc,
      ),
      AuthFeatureCardData(
        icon: Icons.bar_chart_rounded,
        title: l10n.authFeatureAnalyticsTitle,
        description: l10n.authFeatureAnalyticsDesc,
      ),
      AuthFeatureCardData(
        icon: Icons.cloud_outlined,
        title: l10n.authFeatureCloudTitle,
        description: l10n.authFeatureCloudDesc,
      ),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: KulmisAuthTheme.heroGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AuthChartGlow()),
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(
              diameter: compact ? 180 : 260,
              color: KulmisAuthTheme.teal.withValues(alpha: 0.1),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 24 : 48,
                compact ? 20 : 36,
                compact ? 24 : 40,
                compact ? 20 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PlatformBrandLogo(
                        size: logoSize,
                        style: BrandLogoStyle.original,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  fontSize: compact ? 20 : 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  TextSpan(text: '${KulmisAuthTheme.shortName} '),
                                  const TextSpan(
                                    text: 'ERP',
                                    style: TextStyle(color: KulmisAuthTheme.teal),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.authBrandTagline,
                              style: GoogleFonts.inter(
                                fontSize: compact ? 11 : 12,
                                color: KulmisAuthTheme.textSoftOnDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 20 : 32),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: KulmisAuthTheme.teal,
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 24),
                  RichText(
                    text: TextSpan(
                      style: KulmisAuthTheme.headingOnDark(size: compact ? 30 : 42),
                      children: [
                        TextSpan(text: '${l10n.authWelcomeBack} '),
                        TextSpan(
                          text: l10n.authWelcomeBackHighlight,
                          style: const TextStyle(color: KulmisAuthTheme.teal),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  Text(
                    l10n.authWelcomeMessage,
                    style: KulmisAuthTheme.bodyOnDark(size: compact ? 14 : 15),
                  ),
                  SizedBox(height: compact ? 20 : 32),
                  if (!compact)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final twoCol = constraints.maxWidth > 420;
                          if (twoCol) {
                            return GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 2.35,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                for (final f in features) AuthFeatureCard(data: f),
                              ],
                            );
                          }
                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: features.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => AuthFeatureCard(data: features[i]),
                          );
                        },
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: features
                          .map(
                            (f) => Chip(
                              avatar: Icon(f.icon, size: 16, color: KulmisAuthTheme.teal),
                              label: Text(
                                f.title,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              ),
                              backgroundColor: KulmisAuthTheme.glassFill,
                              side: const BorderSide(color: KulmisAuthTheme.glassBorder),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
