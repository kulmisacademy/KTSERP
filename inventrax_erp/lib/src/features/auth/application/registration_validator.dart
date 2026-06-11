import '../../../core/phone/phone_normalizer.dart';

class RegistrationValidationResult {
  const RegistrationValidationResult({required this.isValid, this.message});

  final bool isValid;
  final String? message;

  static const ok = RegistrationValidationResult(isValid: true);
}

class RegistrationValidator {
  const RegistrationValidator._();

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static RegistrationValidationResult validateEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return const RegistrationValidationResult(
        isValid: false,
        message: 'Email is required',
      );
    }
    if (!_emailRe.hasMatch(trimmed)) {
      return const RegistrationValidationResult(
        isValid: false,
        message: 'Enter a valid email address',
      );
    }
    return RegistrationValidationResult.ok;
  }

  static RegistrationValidationResult validatePhone(String phone) {
    final result = PhoneNormalizer.normalizeSomali(phone);
    if (!result.ok) {
      return RegistrationValidationResult(
        isValid: false,
        message: result.error ?? 'Invalid phone number',
      );
    }
    return RegistrationValidationResult.ok;
  }

  static String normalizePhoneE164(String phone) {
    final r = PhoneNormalizer.normalizeSomali(phone);
    return r.ok ? r.e164 : phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String maskPhone(String phone) => PhoneNormalizer.mask(phone);
}
