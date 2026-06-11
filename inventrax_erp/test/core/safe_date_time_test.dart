import 'package:flutter_test/flutter_test.dart';
import 'package:inventrax_erp/src/core/utils/date_time_parse.dart';

void main() {
  test('parses ISO without timezone (Supabase style)', () {
    final dt = SafeDateTime.tryParse('2026-06-01T18:23:42.587');
    expect(dt, isNotNull);
    expect(dt!.isUtc, isTrue);
  });

  test('parses ISO with Z', () {
    final dt = SafeDateTime.tryParse('2026-06-01T18:23:42.587Z');
    expect(dt, isNotNull);
  });

  test('parses unix seconds', () {
    final dt = SafeDateTime.tryParse(1717268622);
    expect(dt, isNotNull);
  });

  test('normalizes sqlite datetime space separator', () {
    final dt = SafeDateTime.tryParse('2026-06-01 18:23:42');
    expect(dt, isNotNull);
  });
}
