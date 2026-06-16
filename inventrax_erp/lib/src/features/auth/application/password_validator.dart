class PasswordValidationResult {
  const PasswordValidationResult({required this.isValid, this.message});

  final bool isValid;
  final String? message;

  static const ok = PasswordValidationResult(isValid: true);
}

/// Letters and/or digits only — min 8 chars. No symbols or case rules.
class PasswordValidator {
  const PasswordValidator._();

  static final _alphanumericOnly = RegExp(r'^[A-Za-z0-9]+$');

  static PasswordValidationResult validate(String password) {
    if (password.length < 8) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Password must be at least 8 characters',
      );
    }
    if (!_alphanumericOnly.hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Use letters and numbers only (no symbols or spaces)',
      );
    }
    return PasswordValidationResult.ok;
  }
}
