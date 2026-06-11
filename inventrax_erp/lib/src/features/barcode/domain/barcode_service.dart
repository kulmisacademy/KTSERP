import 'dart:math';

/// Barcode generation and validation utilities (offline, no network).
class BarcodeService {
  BarcodeService._();

  static final _rng = Random();

  /// InventraX internal CODE128-style numeric codes (store-scoped uniqueness checked in DB).
  static String generateCode128({String prefix = '20'}) {
    final body = List.generate(10, (_) => _rng.nextInt(10)).join();
    return '$prefix$body';
  }

  /// EAN-13 with valid check digit (12 random digits + checksum).
  static String generateEan13() {
    final digits = List.generate(12, (_) => _rng.nextInt(10));
    final check = _ean13CheckDigit(digits);
    return '${digits.join()}$check';
  }

  static int _ean13CheckDigit(List<int> digits) {
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += digits[i] * (i.isEven ? 1 : 3);
    }
    return (10 - (sum % 10)) % 10;
  }

  static bool isValidEan13(String code) {
    final c = code.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{13}$').hasMatch(c)) return false;
    final digits = c.split('').map(int.parse).toList();
    return digits.last == _ean13CheckDigit(digits.sublist(0, 12));
  }

  static String normalize(String raw) => raw.trim();
}

enum BarcodeSymbology {
  code128('code128'),
  ean13('ean13'),
  qr('qr');

  const BarcodeSymbology(this.value);
  final String value;
}
