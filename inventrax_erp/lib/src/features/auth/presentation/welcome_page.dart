import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/l10n_extension.dart';
import 'theme/kulmis_auth_theme.dart';
import 'widgets/auth_premium_button.dart';
import 'widgets/premium_auth_scaffold.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PremiumAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              style: KulmisAuthTheme.formTitle(),
              children: [
                TextSpan(text: '${l10n.authSignInTo} '),
                TextSpan(
                  text: KulmisAuthTheme.systemName,
                  style: const TextStyle(color: KulmisAuthTheme.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l10n.welcomeSubtitle, style: KulmisAuthTheme.formSubtitle()),
          const SizedBox(height: 36),
          AuthPremiumButton(
            label: l10n.welcomeSignIn,
            icon: Icons.login_rounded,
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => context.go('/register'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: KulmisAuthTheme.borderLight),
            ),
            child: Text(
              l10n.registerYourStore,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: KulmisAuthTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
