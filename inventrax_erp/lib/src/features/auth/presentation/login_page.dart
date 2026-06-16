import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/support/support_whatsapp.dart';
import '../../../core/store_context.dart';
import '../application/auth_exception.dart';
import '../application/secure_session_store.dart';
import '../application/session_provider.dart';
import 'theme/kulmis_auth_theme.dart';
import 'widgets/auth_premium_button.dart';
import 'widgets/auth_premium_input.dart';
import 'widgets/premium_auth_scaffold.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _rememberMe = true;
  var _obscure = true;
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final saved = await SecureSessionStore().readRememberEmail();
    if (saved != null && mounted) _email.text = saved;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).signIn(
            email: _email.text,
            password: _password.text,
            rememberMe: _rememberMe,
          );
      if (!mounted) return;
      if (StoreContext.isSuperAdmin) {
        context.go('/platform/dashboard');
      } else {
        context.go('/dashboard');
      }
    } on AuthException catch (e) {
      if (mounted) _showAuthError(e);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.signInFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAuthError(AuthException e) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.code == 'no_profile'
              ? '${e.message}\n\n${l10n.authNoProfileHint}'
              : e.message,
        ),
        backgroundColor: Colors.red.shade700,
        duration: e.code == 'no_profile'
            ? const Duration(seconds: 8)
            : const Duration(seconds: 4),
        action: e.code == 'network'
            ? SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: _signIn,
              )
            : e.code == 'no_profile'
                ? SnackBarAction(
                    label: l10n.registerYourStore,
                    textColor: Colors.white,
                    onPressed: () {
                      final email = Uri.encodeComponent(_email.text.trim());
                      context.go('/register?email=$email');
                    },
                  )
                : null,
      ),
    );
  }

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
          Text(l10n.authEnterCredentials, style: KulmisAuthTheme.formSubtitle()),
          const SizedBox(height: 32),
          AuthPremiumInput(
            label: l10n.authEmailAddress,
            hint: l10n.authEmailHint,
            controller: _email,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: 20),
          AuthPremiumInput(
            label: l10n.password,
            hint: l10n.authPasswordHint,
            controller: _password,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscure,
            onSubmitted: (_) => _signIn(),
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: KulmisAuthTheme.textMuted,
                size: 22,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: KulmisAuthTheme.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: _loading ? null : (v) => setState(() => _rememberMe = v ?? true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.rememberMe,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KulmisAuthTheme.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : () => context.go('/forgot-password'),
                child: Text(
                  l10n.authForgotPassword,
                  style: GoogleFonts.inter(
                    color: KulmisAuthTheme.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthPremiumButton(
            label: _loading ? l10n.signingIn : l10n.signIn,
            icon: Icons.lock_outline_rounded,
            loading: _loading,
            onPressed: _loading ? null : _signIn,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.authNewToBrand(KulmisAuthTheme.systemName),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: KulmisAuthTheme.textMuted,
                ),
              ),
              TextButton(
                onPressed: _loading ? null : () => context.go('/register'),
                child: Text(
                  l10n.authCreateAccount,
                  style: GoogleFonts.inter(
                    color: KulmisAuthTheme.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loading
                ? null
                : () => SupportWhatsApp.openChatOrSnackBar(
                      context,
                      message: l10n.supportWhatsAppPrefill,
                      unavailableMessage: l10n.supportWhatsAppUnavailable,
                    ),
            icon: Icon(Icons.chat_outlined, color: Colors.green.shade600, size: 20),
            label: Text(
              l10n.supportWhatsAppTitle,
              style: GoogleFonts.inter(
                color: KulmisAuthTheme.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
