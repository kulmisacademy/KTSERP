import 'dart:async';



import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'app_database.dart';



AppDatabase? _sharedDb;

Completer<void>? _schemaReady;



/// Opens the local DB once and applies any missing column repairs (web-safe).

Future<AppDatabase> openAppDatabase() async {

  _sharedDb ??= AppDatabase();

  if (_schemaReady == null) {

    final c = Completer<void>();

    _schemaReady = c;

    try {

      await _sharedDb!.ensureSchemaReady();

      c.complete();

    } catch (e, st) {

      c.completeError(e, st);

      _schemaReady = null;

      rethrow;

    }

  } else if (!_schemaReady!.isCompleted) {

    await _schemaReady!.future;

  }

  return _sharedDb!;

}



final appDatabaseProvider = Provider<AppDatabase>((ref) {

  final db = _sharedDb;

  if (db == null) {

    throw StateError(

      'Database not initialized. Call openAppDatabase() in main() first.',

    );

  }

  // Singleton DB — do not close on provider dispose (survives hot restart).

  return db;

});


