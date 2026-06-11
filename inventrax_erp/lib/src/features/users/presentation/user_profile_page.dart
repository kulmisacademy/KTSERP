import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/store_context.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../application/users_repository.dart';
import '../domain/app_permission.dart';
import '../domain/store_user.dart';

final userProfileProvider = FutureProvider.autoDispose.family<StoreUser?, String>(
  (ref, id) => ref.watch(usersRepositoryProvider).getUser(id),
);

final _userPermsProvider = FutureProvider.autoDispose.family<Set<String>, String>(
  (ref, userId) async {
    final user = await ref.watch(usersRepositoryProvider).getUser(userId);
    if (user == null) return {};
    return ref.watch(usersRepositoryProvider).resolveEffectivePermissions(user);
  },
);

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider(userId));
    final permsAsync = ref.watch(_userPermsProvider(userId));

    return AppShell(
      title: 'User profile',
      child: user.when(
        data: (u) {
          if (u == null) {
            return const Center(child: Text('User not found'));
          }
          final perms = permsAsync.value ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        child: Text(
                          u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.fullName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(u.email),
                            Text('${u.roleLabel} · ${u.statusLabel}'),
                            if (u.lastLoginAt != null)
                              Text(
                                'Last login ${DateFormat.yMMMd().add_jm().format(u.lastLoginAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      if (StoreContext.can(AppPermission.usersPermissions))
                        IconButton(
                          onPressed: () => context.go('/users/$userId/permissions'),
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          tooltip: 'Permissions',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role permissions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final p in perms.take(16))
                            Chip(label: Text(p), visualDensity: VisualDensity.compact),
                          if (perms.length > 16)
                            Chip(
                              label: Text('+${perms.length - 16} more'),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
