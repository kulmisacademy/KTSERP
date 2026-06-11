import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventrax_erp/src/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

import '../support/test_database.dart';

const _uuid = Uuid();

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.ensureSchemaReady();
  });

  tearDown(() async {
    await db.close();
  });

  test('atomic stock deducts without going negative', () async {
    const productId = 'prod-stock-1';
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: productId,
            tenantId: testTenantId,
            storeId: testStoreId,
            name: 'Test item',
            purchasePriceCents: 100,
            sellingPriceCents: 200,
            quantity: const Value(10),
          ),
        );

    const saleId = 'sale-1';
    await db.createSaleWithItems(
      sale: SalesCompanion.insert(
        id: saleId,
        tenantId: testTenantId,
        storeId: testStoreId,
        subtotalCents: 800,
        totalCents: 800,
        paymentJson: '{}',
      ),
      items: [
        SaleItemsCompanion.insert(
          id: _uuid.v4(),
          tenantId: testTenantId,
          storeId: testStoreId,
          saleId: saleId,
          productId: Value(productId),
          name: 'Test item',
          quantity: 8,
          unitPriceCents: 100,
          lineTotalCents: 800,
        ),
      ],
    );

    final row = await db.getProductById(
      storeId: testStoreId,
      productId: productId,
    );
    expect(row!.quantity, 2);
  });

  test('oversell clamps quantity to zero not negative', () async {
    const productId = 'prod-stock-2';
    await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: productId,
            tenantId: testTenantId,
            storeId: testStoreId,
            name: 'Low stock',
            purchasePriceCents: 50,
            sellingPriceCents: 100,
            quantity: const Value(2),
          ),
        );

    const saleId = 'sale-oversell';
    await db.createSaleWithItems(
      sale: SalesCompanion.insert(
        id: saleId,
        tenantId: testTenantId,
        storeId: testStoreId,
        subtotalCents: 500,
        totalCents: 500,
        paymentJson: '{}',
      ),
      items: [
        SaleItemsCompanion.insert(
          id: _uuid.v4(),
          tenantId: testTenantId,
          storeId: testStoreId,
          saleId: saleId,
          productId: Value(productId),
          name: 'Low stock',
          quantity: 5,
          unitPriceCents: 100,
          lineTotalCents: 500,
        ),
      ],
    );

    final row = await db.getProductById(
      storeId: testStoreId,
      productId: productId,
    );
    expect(row!.quantity, greaterThanOrEqualTo(0));
    expect(row.quantity, 0);
  });
}
