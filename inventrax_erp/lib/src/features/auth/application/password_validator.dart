class PasswordValidationResult {
  const PasswordValidationResult({required this.isValid, this.message});

  final bool isValid;
  final String? message;

  static const ok = PasswordValidationResult(isValid: true);
}

class PasswordValidator {
  const PasswordValidator._();

  static PasswordValidationResult validate(String password) {
    if (password.length < 8) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Password must be at least 8 characters',
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Include at least one uppercase letter',
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Include at least one lowercase letter',
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Include at least one number',
      );
    }
    return PasswordValidationResult.ok;
  }
}
