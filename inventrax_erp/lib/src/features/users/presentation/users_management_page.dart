import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/ux/responsive.dart';
import '../../../core/store_context.dart';
import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_empty_state.dart';
import '../../../ui/layout/app_shell.dart';
import '../application/users_repository.dart';
import '../domain/app_permission.dart';
import '../domain/store_user.dart';

class UsersManagementPage extends ConsumerWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(storeUsersProvider);
    final isMobile = Responsive.isMobile(context);
    final canManage = StoreContext.can(AppPermission.usersManage);

    return AppShell(
      title: 'User Management',
      actions: [
        if (canManage)
          AppButton(
            label: 'Create user',
            icon: Icons.person_add,
            onPressed: () => context.go('/users/create'),
          ),
        const SizedBox(width: 8),
      ],
      child: users.when(
        data: (list) {
          if (list.isEmpty) {
            return AppEmptyState(
              icon: Icons.people_outline,
              title: 'No staff yet',
              subtitle: 'Create employees, cashiers, and managers for your store.',
              action: canManage
                  ? FilledButton(
                      onPressed: () => context.go('/users/create'),
                      child: const Text('Create user'),
                    )
                  : null,
            );
          }
          if (isMobile) {
            return ListView.separated(
              padding: Responsive.pagePadding(context),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _UserCard(user: list[i], canManage: canManage),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Last login')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  for (final u in list)
                    DataRow(
                      cells: [
                        DataCell(_UserCell(user: u)),
                        DataCell(Text(u.roleLabel)),
                        DataCell(_StatusChip(user: u)),
                        DataCell(Text(
                          u.lastLoginAt != null
                              ? DateFormat.yMMMd().add_jm().format(u.lastLoginAt!)
                              : '—',
                        )),
                        DataCell(_UserActions(user: u, canManage: canManage)),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load users: $e')),
      ),
    );
  }
}

class _UserCell extends StatelessWidget {
  const _UserCell({required this.user});
  final StoreUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?')
              : null,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.user});
  final StoreUser user;

  @override
  Widget build(BuildContext context) {
    final active = user.isActive && user.status == 'active';
    return Chip(
      label: Text(active ? 'Active' : 'Suspended'),
      backgroundColor: active
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.orange.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: active ? Colors.green.shade800 : Colors.orange.shade900,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _UserActions extends ConsumerWidget {
  const _UserActions({required this.user, required this.canManage});
  final StoreUser user;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (v) async {
        final repo = ref.read(usersRepositoryProvider);
        switch (v) {
          case 'permissions':
            if (context.mounted) {
              context.go('/users/${user.id}/permissions');
            }
          case 'suspend':
            await repo.updateUser(
              userId: user.id,
              isActive: false,
              status: 'suspended',
            );
            ref.invalidate(storeUsersProvider);
          case 'activate':
            await repo.updateUser(
              userId: user.id,
              isActive: true,
              status: 'active',
            );
            ref.invalidate(storeUsersProvider);
          case 'profile':
            if (context.mounted) context.go('/users/${user.id}');
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'profile', child: Text('View profile')),
        if (StoreContext.can(AppPermission.usersPermissions))
          const PopupMenuItem(
            value: 'permissions',
            child: Text('Edit permissions'),
          ),
        if (canManage && user.isActive)
          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
        if (canManage && !user.isActive)
          const PopupMenuItem(value: 'activate', child: Text('Activate')),
      ],
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user, required this.canManage});
  final StoreUser user;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: ListTile(
        leading: CircleAvatar(child: Text(user.fullName[0].toUpperCase())),
        title: Text(user.fullName),
        subtitle: Text('${user.roleLabel} · ${user.email}'),
        trailing: _UserActions(user: user, canManage: canManage),
        onTap: () => context.go('/users/${user.id}'),
      ),
    );
  }
}
