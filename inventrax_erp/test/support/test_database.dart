import 'package:drift/native.dart';
import 'package:inventrax_erp/src/data/local/app_database.dart';

/// Fresh in-memory database with default seed data.
AppDatabase createTestDatabase() {
  return AppDatabase.forTest(NativeDatabase.memory());
}

const testTenantId = 'dev-tenant';
const testStoreId = 'dev-store';
