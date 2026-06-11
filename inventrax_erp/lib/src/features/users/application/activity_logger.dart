import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../sync/supabase_bootstrap.dart';

/// Records user actions locally and on Supabase when available.
class ActivityLogger {
  ActivityLogger(this._db);

  final AppDatabase _db;

  Future<void> log({
    required String action,
    String? entity,
    String? entityId,
    String? oldValue,
    String? newValue,
  }) async {
    final userId = StoreContext.userId;
    if (userId == null) return;

    await _db.recordAuditLog(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      userId: userId,
      entity: entity ?? 'system',
      entityId: entityId ?? '',
      action: action,
      oldValue: oldValue,
      newValue: newValue,
    );

    if (!SupabaseConfig.isConfigured) return;
    final client = supabaseClient;
    if (client == null) return;

    try {
      await client.rpc('log_user_activity', params: {
        'p_action': action,
        'p_entity': entity,
        'p_entity_id': entityId,
        'p_old_value': oldValue != null ? {'v': oldValue} : null,
        'p_new_value': newValue != null ? {'v': newValue} : null,
      });
    } catch (_) {}
  }
}

final activityLoggerProvider = Provider<ActivityLogger>((ref) {
  return ActivityLogger(ref.watch(appDatabaseProvider));
});
