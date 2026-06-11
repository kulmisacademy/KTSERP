import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventrax_erp/src/data/local/app_database.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.ensureSchemaReady();
  });

  tearDown(() async {
    await db.close();
  });

  test('sales keyset pagination has no duplicates across pages', () async {
    final now = DateTime.now();
    for (var i = 0; i < 120; i++) {
      final id = 'sale-page-$i';
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: id,
              tenantId: testTenantId,
              storeId: testStoreId,
              subtotalCents: 100,
              totalCents: 100,
              paymentJson: '{}',
              createdAt: Value(now.subtract(Duration(minutes: i))),
            ),
          );
    }

    final from = now.subtract(const Duration(days: 1));
    final to = now.add(const Duration(days: 1));
    final seen = <String>{};
    var cursor = await db.fetchSalesPage(
      storeId: testStoreId,
      from: from,
      to: to,
      limit: 40,
    );
    for (final e in cursor.items) {
      expect(seen.add(e.sale.id), isTrue, reason: 'duplicate ${e.sale.id}');
    }

    while (cursor.hasMore) {
      cursor = await db.fetchSalesPage(
        storeId: testStoreId,
        from: from,
        to: to,
        limit: 40,
        cursor: cursor.nextCursor,
      );
      for (final e in cursor.items) {
        expect(seen.add(e.sale.id), isTrue, reason: 'duplicate ${e.sale.id}');
      }
    }

    expect(seen.length, 120);
  });
}
