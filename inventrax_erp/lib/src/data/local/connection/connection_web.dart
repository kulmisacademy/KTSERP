import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase openConnectionPlatform() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'inventrax_erp',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
