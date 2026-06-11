import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../application/auth_exception.dart';
import '../application/password_validator.dart';
import '../application/registration_validator.dart';
import '../application/session_provider.dart';
import '../data/registration_service.dart';
import '../domain/registration_data.dart';
import 'theme/kulmis_auth_theme.dart';
import 'widgets/auth_premium_button.dart';
import 'widgets/auth_premium_input.dart';
import 'widgets/auth_step_indicator.dart';
import 'widgets/premium_auth_scaffold.dart';

class RegisterStorePage extends ConsumerStatefulWidget {
  const RegisterStorePage({super.key, this.prefillEmail});

  /// Pre-filled when user has Auth account but no store profile yet.
  final String? prefillEmail;

  @override
  ConsumerState<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends ConsumerState<RegisterStorePage> {
  final _page = PageController();
  var _step = 0;
  var _loading = false;
  var _prechecking = false;
  var _obscure = true;
  final _storeName = TextEditingController();
  final _businessType = TextEditingController(text: 'Retail');
  final _country = TextEditingController(text: 'Somalia');
  final _currency = TextEditingController(text: 'USD (\$)');
  final _address = TextEditingController();
  final _taxNumber = TextEditingController();
  final _ownerName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    final email = widget.prefillEmail?.trim();
    if (email != null && email.isNotEmpty) {
      _email.text = email;
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _storeName.dispose();
    _businessType.dispose();
    _country.dispose();
    _currency.dispose();
    _address.dispose();
    _taxNumber.dispose();
    _ownerName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _next() {
    final l10n = context.l10n;
    if (_step == 0 && _storeName.text.trim().isEmpty) {
      _showError(l10n.storeNameRequired);
      return;
    }
    if (_step == 1) {
      if (_ownerName.text.trim().isEmpty) {
        _showError(l10n.ownerNameRequired);
        return;
      }
      if (_email.text.trim().isEmpty) {
        _showError(l10n.emailRequired);
        return;
      }
      final emailCheck = RegistrationValidator.validateEmail(_email.text);
      if (!emailCheck.isValid) {
        _showError(emailCheck.message ?? l10n.emailRequired);
        return;
      }
      final pwd = PasswordValidator.validate(_password.text);
      if (!pwd.isValid) {
        _showError(pwd.message ?? l10n.invalidPassword);
        return;
      }
      if (_password.text != _confirmPassword.text) {
        _showError(l10n.passwordsDoNotMatch);
        return;
      }
      final phoneCheck = RegistrationValidator.validatePhone(_phone.text);
      if (!phoneCheck.isValid) {
        _showError(phoneCheck.message ?? 'Valid phone required');
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
      _page.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _createStore();
  }

  String get _normalizedCurrency {
    final raw = _currency.text.trim().toUpperCase();
    final match = RegExp(r'^[A-Z]{3}').firstMatch(raw);
    return match?.group(0) ?? 'USD';
  }

  RegistrationData get _registrationData => RegistrationData(
        storeName: _storeName.text,
        businessType: _businessType.text,
        country: _country.text.isEmpty ? 'Somalia' : _country.text,
        currencyCode: _normalizedCurrency,
        address: _address.text,
        ownerName: _ownerName.text,
        email: _email.text,
        phone: _normalizedPhone,
        password: _password.text,
        taxNumber: _taxNumber.text.trim().isEmpty ? null : _taxNumber.text,
      );

  /// Precheck email/phone, then create account + store immediately (no OTP).
  Future<void> _createStore() async {
    final l10n = context.l10n;
    final emailCheck = RegistrationValidator.validateEmail(_email.text);
    if (!emailCheck.isValid) {
      _showError(emailCheck.message!);
      return;
    }
    final phoneCheck = RegistrationValidator.validatePhone(_phone.text);
    if (!phoneCheck.isValid) {
      _showError(phoneCheck.message!);
      return;
    }

    setState(() => _prechecking = true);
    try {
      final precheck = await ref
          .read(registrationServiceProvider)
          .precheckRegistration(
            email: _email.text.trim(),
            phone: _phone.text.trim(),
          );

      if (precheck.status == RegistrationEmailStatus.hasStore) {
        _showError(
          precheck.message ??
              'This email already has a store. Please sign in.',
        );
        return;
      }

      if (precheck.status == RegistrationEmailStatus.invalid) {
        _showError(precheck.message ?? 'Invalid email');
        return;
      }

      await _finalizeRegistration();
    } catch (_) {
      if (mounted) _showError(l10n.registrationFailed);
    } finally {
      if (mounted) setState(() => _prechecking = false);
    }
  }

  String get _normalizedPhone =>
      RegistrationValidator.normalizePhoneE164(_phone.text);

  void _back() {
    if (_step == 0) {
      context.go('/login');
      return;
    }
    setState(() => _step--);
    _page.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _finalizeRegistration() async {
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).registerStore(_registrationData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome! ${_storeName.text.trim()} is ready on KULMIS ERP.',
          ),
          backgroundColor: KulmisAuthTheme.teal,
        ),
      );
      context.go('/dashboard');
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError(context.l10n.registrationFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      l10n.registerStepBusiness,
      l10n.registerStepOwner,
      l10n.registerStepReview,
    ];

    return PremiumAuthScaffold(
      fillHeight: true,
      child: Column(
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
                  l10n.registerYourStore,
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
          AuthStepIndicator(steps: steps, currentStep: _step),
          const SizedBox(height: 24),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _businessStep(),
                _ownerStep(),
                _reviewStep(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AuthPremiumButton(
            label: _loading
                ? l10n.creatingStore
                : (_prechecking
                    ? 'Checking…'
                    : (_step < 2
                        ? l10n.onboardingContinue
                        : l10n.createStore)),
            icon: _step < 2
                ? Icons.arrow_forward_rounded
                : Icons.storefront_rounded,
            loading: _loading || _prechecking,
            onPressed: (_loading || _prechecking) ? null : _next,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _loading ? null : () => context.go('/login'),
              child: Text(
                l10n.alreadyHaveAccountSignIn,
                style: GoogleFonts.inter(
                  color: KulmisAuthTheme.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: KulmisAuthTheme.formSubtitle(),
    );
  }

  Widget _businessStep() {
    final l10n = context.l10n;
    return ListView(
      children: [
        _sectionTitle(l10n.tellUsBusiness),
        const SizedBox(height: 20),
        AuthPremiumInput(
          label: l10n.storeNameField,
          hint: l10n.authStoreNameHint,
          controller: _storeName,
          prefixIcon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.businessType,
          hint: l10n.authBusinessTypeHint,
          controller: _businessType,
          prefixIcon: Icons.category_outlined,
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthPremiumInput(
                label: l10n.country,
                hint: l10n.authCountryHint,
                controller: _country,
                prefixIcon: Icons.public_outlined,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AuthPremiumInput(
                label: l10n.currencyLabel,
                hint: l10n.authCurrencyHint,
                controller: _currency,
                prefixIcon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.settingsAddress,
          hint: l10n.authAddressHint,
          controller: _address,
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.taxNumberOptional,
          hint: l10n.taxNumberOptional,
          controller: _taxNumber,
          prefixIcon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  Widget _ownerStep() {
    final l10n = context.l10n;
    final finishingSetup = widget.prefillEmail != null && widget.prefillEmail!.isNotEmpty;
    return ListView(
      children: [
        _sectionTitle(l10n.ownerAccountTitle),
        if (finishingSetup) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: KulmisAuthTheme.teal.withValues(alpha: 0.08),
              border: Border.all(color: KulmisAuthTheme.teal.withValues(alpha: 0.25)),
            ),
            child: Text(
              'Your login exists but no store is linked yet. Use the same password '
              'you use to sign in, then create your store.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: KulmisAuthTheme.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        AuthPremiumInput(
          label: l10n.fullName,
          hint: l10n.authFullNameHint,
          controller: _ownerName,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.email,
          hint: l10n.authEmailHint,
          controller: _email,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.phoneRequired,
          hint: l10n.authPhoneHint,
          controller: _phone,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.password,
          hint: l10n.authPasswordHint,
          controller: _password,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscure,
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: KulmisAuthTheme.textMuted,
              size: 22,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.passwordHint,
          style: GoogleFonts.inter(fontSize: 12, color: KulmisAuthTheme.textMuted),
        ),
        const SizedBox(height: 18),
        AuthPremiumInput(
          label: l10n.confirmPassword,
          hint: l10n.authConfirmPasswordHint,
          controller: _confirmPassword,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscure,
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final l10n = context.l10n;
    return ListView(
      children: [
        _sectionTitle(l10n.reviewCreateStore),
        const SizedBox(height: 20),
        _reviewTile(l10n.reviewLabelStore, _storeName.text),
        _reviewTile(l10n.reviewLabelType, _businessType.text),
        _reviewTile(l10n.reviewLabelLocation, '${_country.text} • ${_currency.text}'),
        _reviewTile(l10n.reviewLabelOwner, _ownerName.text),
        _reviewTile(l10n.email, _email.text),
        _reviewTile(l10n.settingsPhone, _phone.text),
        const SizedBox(height: 16),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: KulmisAuthTheme.teal.withValues(alpha: 0.08),
            border: Border.all(color: KulmisAuthTheme.teal.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KulmisAuthTheme.teal.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.card_giftcard, color: KulmisAuthTheme.teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.freeTrial14Day,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: KulmisAuthTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.storeOwnerPermissions,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: KulmisAuthTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: KulmisAuthTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: KulmisAuthTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
