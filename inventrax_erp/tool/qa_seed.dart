// ignore_for_file: avoid_print
/// Large-dataset seed for local performance QA.
///
/// Usage (from inventrax_erp/):
///   dart run tool/qa_seed.dart --products 5000 --sales 20000
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:inventrax_erp/src/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const tenantId = 'dev-tenant';
const storeId = 'dev-store';

Future<void> main(List<String> args) async {
  var productCount = 1000;
  var saleCount = 5000;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--products' && i + 1 < args.length) {
      productCount = int.parse(args[i + 1]);
    }
    if (args[i] == '--sales' && i + 1 < args.length) {
      saleCount = int.parse(args[i + 1]);
    }
  }

  final dbFile = File('inventrax_qa_seed.sqlite');
  if (await dbFile.exists()) await dbFile.delete();
  print('Seeding ${dbFile.path}');

  final db = AppDatabase.forTest(NativeDatabase(dbFile));
  await db.ensureSchemaReady();

  print('Inserting $productCount products…');
  await db.batch((b) {
    for (var i = 0; i < productCount; i++) {
      b.insert(
        db.products,
        ProductsCompanion.insert(
          id: _uuid.v4(),
          tenantId: tenantId,
          storeId: storeId,
          name: 'QA Product $i',
          barcode: Value('QA${i.toString().padLeft(8, '0')}'),
          purchasePriceCents: 100 + (i % 50),
          sellingPriceCents: 200 + (i % 80),
          quantity: Value(20 + (i % 100)),
        ),
      );
    }
  });

  print('Inserting $saleCount sales…');
  final now = DateTime.now();
  await db.batch((b) {
    for (var i = 0; i < saleCount; i++) {
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: _uuid.v4(),
          tenantId: tenantId,
          storeId: storeId,
          subtotalCents: 500 + (i % 200),
          totalCents: 500 + (i % 200),
          paymentJson: '{}',
          paymentStatus: Value(i.isEven ? 'paid' : 'partially_paid'),
          createdAt: Value(now.subtract(Duration(minutes: i))),
        ),
      );
    }
  });

  await db.rebuildLocalIndexes();
  final bytes = await dbFile.length();
  await db.close();
  print('Done. DB size: ${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB');
  print('Point app at this file or copy into app support dir for testing.');
}
