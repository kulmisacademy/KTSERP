import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../application/password_validator.dart';
import '../application/registration_validator.dart';
import '../data/email_reset_service.dart';
import 'theme/kulmis_auth_theme.dart';
import 'widgets/auth_premium_button.dart';
import 'widgets/auth_premium_input.dart';
import 'widgets/auth_step_indicator.dart';
import 'widgets/otp_input_widget.dart';
import 'widgets/premium_auth_scaffold.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const _steps = ['Email', 'Verify', 'Password'];

  var _step = 0;
  var _loading = false;
  var _obscure = true;
  var _resendSec = 0;
  var _expiresSec = EmailResetService.otpExpirySec;
  Timer? _cooldownTimer;
  Timer? _expiryTimer;

  String? _requestId;
  String? _resetToken;
  String? _devOtp;
  var _devMode = false;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _otpKey = GlobalKey<OtpInputWidgetState>();

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _expiryTimer?.cancel();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _back() {
    if (_step == 0) {
      context.go('/login');
      return;
    }
    setState(() => _step--);
  }

  void _startCooldown([int seconds = EmailResetService.resendCooldownSec]) {
    _cooldownTimer?.cancel();
    setState(() => _resendSec = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSec <= 1) {
        t.cancel();
        setState(() => _resendSec = 0);
      } else {
        setState(() => _resendSec--);
      }
    });
  }

  void _startExpiryTimer([int seconds = EmailResetService.otpExpirySec]) {
    _expiryTimer?.cancel();
    setState(() => _expiresSec = seconds);
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_expiresSec <= 1) {
        t.cancel();
        setState(() => _expiresSec = 0);
      } else {
        setState(() => _expiresSec--);
      }
    });
  }

  Future<void> _sendEmailOtp() async {
    final raw = _email.text.trim();
    final emailCheck = RegistrationValidator.validateEmail(raw);
    if (!emailCheck.isValid) {
      _showError(emailCheck.message ?? 'Enter a valid email');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref.read(emailResetServiceProvider).sendResetOtp(raw);
      if (!mounted) return;
      setState(() {
        _step = 1;
        _requestId = result.requestId;
        _resetToken = null;
        _devMode = result.devMode;
        _devOtp = result.devOtp;
      });
      _startCooldown(result.resendCooldownSec);
      _startExpiryTimer(result.expiresInSec);
      _otpKey.currentState?.clear();
      if (result.devMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Dev mode: no email sent. Use code ${result.devOtp ?? '123456'}.',
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent to $raw. Check inbox and spam.',
            ),
            backgroundColor: KulmisAuthTheme.teal,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on EmailResetException catch (e) {
      if (mounted) {
        _showError(e.message);
        if (e.retryAfterSec != null) _startCooldown(e.retryAfterSec!);
      }
    } catch (_) {
      if (mounted) {
        _showError('Could not send code. Check the email and try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSec > 0) return;
    await _sendEmailOtp();
  }

  Future<void> _verifyOtp(String code) async {
    if (code.length < 6) return;
    if (_expiresSec <= 0) {
      _showError('Code expired. Tap Resend code.');
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref.read(emailResetServiceProvider).verifyResetOtp(
            email: _email.text.trim(),
            code: code,
            requestId: _requestId,
          );
      if (!mounted) return;
      setState(() {
        _step = 2;
        _requestId = result.requestId;
        _resetToken = result.resetToken;
      });
      _expiryTimer?.cancel();
    } on EmailResetException catch (e) {
      if (mounted) {
        _showError(e.message);
        _otpKey.currentState?.clear();
      }
    } catch (_) {
      if (mounted) _showError('Invalid or expired code');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final pwd = PasswordValidator.validate(_password.text);
    if (!pwd.isValid) {
      _showError(pwd.message ?? 'Invalid password');
      return;
    }
    if (_password.text != _confirm.text) {
      _showError(context.l10n.passwordsDoNotMatch);
      return;
    }
    final requestId = _requestId;
    final resetToken = _resetToken;
    if (requestId == null || resetToken == null) {
      _showError('Verification expired. Start again.');
      setState(() => _step = 0);
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(emailResetServiceProvider).resetPassword(
            email: _email.text.trim(),
            requestId: requestId,
            resetToken: resetToken,
            newPassword: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated. Sign in with your new password.'),
        ),
      );
      context.go('/login');
    } on EmailResetException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Password reset failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PremiumAuthScaffold(
      fillHeight: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: Column(
          key: ValueKey(_step),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _loading ? null : _back,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: KulmisAuthTheme.textDark,
                ),
                Expanded(
                  child: Text(
                    l10n.authForgotPassword,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KulmisAuthTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 16),
            AuthStepIndicator(steps: _steps, currentStep: _step),
            const SizedBox(height: 24),
            Expanded(child: _buildStep()),
            if (_step != 1) ...[
              const SizedBox(height: 16),
              AuthPremiumButton(
                label: _step == 0
                    ? 'Send verification code'
                    : (_loading ? l10n.saving : 'Reset password'),
                icon: _step == 0
                    ? Icons.mail_outline_rounded
                    : Icons.lock_reset_rounded,
                loading: _loading,
                onPressed: _loading
                    ? null
                    : (_step == 0 ? _sendEmailOtp : _resetPassword),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    final l10n = context.l10n;
    switch (_step) {
      case 0:
        return ListView(
          children: [
            Text('Recover your account', style: KulmisAuthTheme.formTitle()),
            const SizedBox(height: 8),
            Text(
              'Enter the email registered with your store account. '
              'We will send a one-time verification code via email.',
              style: KulmisAuthTheme.formSubtitle(),
            ),
            const SizedBox(height: 28),
            AuthPremiumInput(
              label: l10n.email,
              hint: l10n.authEmailHint,
              controller: _email,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        );
      case 1:
        final expiryLabel = _expiresSec > 0
            ? 'Code expires in ${_expiresSec ~/ 60}:${(_expiresSec % 60).toString().padLeft(2, '0')}'
            : 'Code expired — resend to continue';
        return ListView(
          children: [
            Text('Enter verification code', style: KulmisAuthTheme.formTitle()),
            const SizedBox(height: 8),
            Text(
              _devMode
                  ? 'Development mode — enter the code shown below'
                  : 'We sent a 6-digit code to ${_email.text.trim()}',
              style: KulmisAuthTheme.formSubtitle(),
              textAlign: TextAlign.center,
            ),
            if (_devMode && _devOtp != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  'Dev code: $_devOtp\n(OTP_DEV_MODE is on — emails are not sent)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
            if (!_devMode) ...[
              const SizedBox(height: 8),
              Text(
                'Check your spam/junk folder if you do not see it within a minute.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: KulmisAuthTheme.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              expiryLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _expiresSec > 0
                    ? KulmisAuthTheme.teal
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 28),
            OtpInputWidget(
              key: _otpKey,
              enabled: !_loading && _expiresSec > 0,
              onCompleted: _verifyOtp,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: (_resendSec > 0 || _loading) ? null : _resendOtp,
                child: Text(
                  _resendSec > 0
                      ? 'Resend in ${_resendSec}s'
                      : 'Resend code',
                  style: GoogleFonts.inter(
                    color: KulmisAuthTheme.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      default:
        return ListView(
          children: [
            Text('Create new password', style: KulmisAuthTheme.formTitle()),
            const SizedBox(height: 8),
            Text(l10n.passwordHint, style: KulmisAuthTheme.formSubtitle()),
            const SizedBox(height: 28),
            AuthPremiumInput(
              label: l10n.password,
              hint: l10n.authPasswordHint,
              controller: _password,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffix: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: KulmisAuthTheme.textMuted,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 18),
            AuthPremiumInput(
              label: l10n.confirmPassword,
              hint: l10n.authConfirmPasswordHint,
              controller: _confirm,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscure,
            ),
          ],
        );
    }
  }
}
