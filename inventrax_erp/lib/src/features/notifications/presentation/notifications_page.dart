import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/l10n/nav_l10n.dart';
import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/layout/app_shell.dart';

final notificationsProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchNotifications(storeId: StoreContext.storeId);
});

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final timeFmt = DateFormat.MMMd().add_jm();

    final l10n = context.l10n;
    return AppShell(
      title: localizedNavLabel(l10n, '/notifications'),
      child: notifications.when(
        data: (rows) {
          if (rows.isEmpty) {
            return AppEmptyState(
              title: l10n.noNotifications,
              subtitle: l10n.noNotificationsSubtitle,
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = rows[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    _iconFor(n.type),
                    size: 20,
                  ),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
                subtitle: Text('${n.body}\n${timeFmt.format(n.createdAt)}'),
                isThreeLine: true,
                onTap: () async {
                  await ref.read(appDatabaseProvider).markNotificationRead(n.id);
                  if (n.type == 'ai_monthly_report' && context.mounted) {
                    context.go('/ai-insights');
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _iconFor(String type) => switch (type) {
        'low_stock' => Icons.warning_amber,
        'debt_due' => Icons.request_quote,
        'expiry' => Icons.event_busy,
        'ai_monthly_report' => Icons.auto_awesome,
        _ => Icons.notifications,
      };
}
