/// Somali phone normalization — matches edge `phone_normalizer.ts`.
class PhoneNormalizeResult {
  const PhoneNormalizeResult({
    required this.ok,
    this.e164 = '',
    this.local = '',
    this.error,
  });

  final bool ok;
  final String e164;
  final String local;
  final String? error;
}

class PhoneNormalizer {
  const PhoneNormalizer._();

  static final _localMobile = RegExp(r'^[679]\d{8}$');

  static String _digitsOnly(String raw) {
    var d = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (d.startsWith('+')) d = d.substring(1);
    if (d.startsWith('00')) d = d.substring(2);
    return d;
  }

  static String? _toLocal(String digits) {
    var d = digits;
    if (d.startsWith('252') && d.length >= 12) {
      d = d.substring(3);
    }
    if (d.startsWith('0') && d.length >= 9) {
      d = d.substring(1);
    }
    if (!_localMobile.hasMatch(d)) return null;
    return d;
  }

  /// Canonical E.164 without +: 252613609678
  static PhoneNormalizeResult normalizeSomali(String raw) {
    final digits = _digitsOnly(raw);
    if (digits.length < 7) {
      return const PhoneNormalizeResult(
        ok: false,
        error: 'Invalid phone number',
      );
    }
    final local = _toLocal(digits);
    if (local == null) {
      return const PhoneNormalizeResult(
        ok: false,
        error:
            'Invalid Somali mobile. Use 061XXXXXXX, 613XXXXXXX, or +25261XXXXXXX',
      );
    }
    return PhoneNormalizeResult(
      ok: true,
      e164: '252$local',
      local: local,
    );
  }

  /// Mask for OTP UI: +252******9678
  static String mask(String raw) {
    final r = normalizeSomali(raw);
    if (!r.ok || r.e164.length < 8) return raw;
    final last4 = r.e164.substring(r.e164.length - 4);
    return '+252******$last4';
  }
}
