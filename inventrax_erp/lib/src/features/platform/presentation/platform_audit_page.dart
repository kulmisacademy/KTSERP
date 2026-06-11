import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../application/platform_providers.dart';
import '../domain/platform_models.dart';
import 'widgets/platform_widgets.dart';

class PlatformAuditPage extends ConsumerWidget {
  const PlatformAuditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(platformAuditLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlatformPageHeader(
          title: 'Audit log',
          subtitle: 'Super admin actions: impersonation, billing, suspensions',
        ),
        Expanded(
          child: logs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => PlatformEmptyState(icon: Icons.error, message: '$e'),
            data: (list) {
              if (list.isEmpty) {
                return const PlatformEmptyState(
                  icon: Icons.history,
                  message: 'No admin activity recorded yet',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(platformAuditLogsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _LogTile(entry: list[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final AdminActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().add_jm().format(entry.createdAt);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _colorFor(entry.action).withValues(alpha: 0.15),
        child: Icon(_iconFor(entry.action), color: _colorFor(entry.action), size: 20),
      ),
      title: Text(entry.action.replaceAll('.', ' → ')),
      subtitle: Text(
        '${entry.adminEmail ?? 'admin'} • $time'
        '${entry.targetId != null ? ' • ${entry.targetType ?? 'target'}: ${entry.targetId}' : ''}',
      ),
    );
  }

  Color _colorFor(String action) {
    if (action.contains('impersonate')) return AppColors.warning;
    if (action.contains('suspend')) return AppColors.error;
    if (action.contains('subscription')) return AppColors.accent;
    return AppColors.primary;
  }

  IconData _iconFor(String action) {
    if (action.contains('impersonate')) return Icons.visibility;
    if (action.contains('suspend')) return Icons.block;
    if (action.contains('subscription')) return Icons.payments;
    return Icons.admin_panel_settings;
  }
}
