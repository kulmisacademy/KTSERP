import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/store_context.dart';
import '../data/local/app_database.dart';
import '../data/local/db_provider.dart';
import '../core/supabase_config.dart';
import '../ui/components/app_button.dart';
import '../ui/components/app_empty_state.dart';
import '../ui/layout/app_shell.dart';
import 'sync_service.dart';

final syncQueueProvider = StreamProvider.autoDispose<List<SyncQueueData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchSyncQueue(
    tenantId: StoreContext.tenantId,
    storeId: StoreContext.storeId,
  );
});

class SyncQueuePage extends ConsumerWidget {
  const SyncQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(syncQueueProvider);
    return AppShell(
      title: 'Sync',
      actions: [
        if (SupabaseConfig.isConfigured)
          TextButton.icon(
            onPressed: () async {
              final n = await ref.read(syncWorkerProvider.notifier).pushNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pushed $n item(s) to cloud')),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Sync now'),
          ),
      ],
      child: rows.when(
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              title: 'Sync queue is empty',
              subtitle: SupabaseConfig.isConfigured
                  ? 'Local changes upload when you tap Sync now.'
                  : 'Configure SUPABASE_URL and SUPABASE_ANON_KEY to enable cloud sync.',
              icon: Icons.sync_outlined,
              action: SupabaseConfig.isConfigured
                  ? AppButton(
                      label: 'Sync now',
                      icon: Icons.cloud_upload_outlined,
                      onPressed: () async {
                        await ref.read(syncWorkerProvider.notifier).pushNow();
                      },
                    )
                  : null,
            );
          }
          return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final q = items[index];
                return ListTile(
                  title: Text('${q.entity} • ${q.operation}'),
                  subtitle: Text(
                    'id=${q.entityId}\n'
                    'retries=${q.retryCount} • ${q.createdAt}'
                    '${q.lastError != null ? '\n${q.lastError}' : ''}',
                  ),
                  isThreeLine: q.lastError != null,
                  trailing: IconButton(
                    tooltip: 'Remove from queue',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref.read(appDatabaseProvider).dropSyncQueueItem(q.id);
                    },
                  ),
                );
              },
            );
          },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

