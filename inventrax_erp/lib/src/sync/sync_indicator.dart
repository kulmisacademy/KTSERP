import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'sync_service.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncWorkerProvider);

    final (color, label) = switch (status.health) {
      SyncHealth.synced => (Colors.green, 'Synced'),
      SyncHealth.syncing => (Colors.amber, 'Syncing'),
      SyncHealth.queued => (Colors.orange, 'Pending sync'),
      SyncHealth.offline => (Colors.red, 'Offline'),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => context.go('/sync'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label),
            if (status.pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${status.pendingCount}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

