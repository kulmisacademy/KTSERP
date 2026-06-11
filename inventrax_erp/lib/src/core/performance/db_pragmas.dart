import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

/// SQLite pragmas for POS-grade write throughput and read concurrency.
Future<void> applySqlitePerformancePragmas(GeneratedDatabase db) async {
  if (kIsWeb) {
    // WASM SQLite: WAL may be unsupported; skip silently.
    return;
  }
  Future<void> pragma(String sql) async {
    try {
      await db.customStatement(sql);
    } catch (_) {}
  }

  await pragma('PRAGMA journal_mode=WAL;');
  await pragma('PRAGMA synchronous=NORMAL;');
  await pragma('PRAGMA temp_store=MEMORY;');
  await pragma('PRAGMA cache_size=-64000;'); // ~64MB page cache
  await pragma('PRAGMA foreign_keys=ON;');
}
