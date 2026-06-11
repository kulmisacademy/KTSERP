import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/layout/app_shell.dart';
import '../application/users_repository.dart';
import '../domain/store_user.dart';
import 'widgets/advanced_permission_panel.dart';

class UserPermissionsPage extends ConsumerStatefulWidget {
  const UserPermissionsPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserPermissionsPage> createState() => _UserPermissionsPageState();
}

class _UserPermissionsPageState extends ConsumerState<UserPermissionsPage> {
  Set<String> _selected = {};
  var _loading = true;
  var _saving = false;
  StoreUser? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(usersRepositoryProvider);
    final user = await repo.getUser(widget.userId);
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final effective = await repo.resolveEffectivePermissions(user);
    setState(() {
      _user = user;
      _selected = effective;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_user == null) return;
    setState(() => _saving = true);
    await ref.read(usersRepositoryProvider).savePermissionSelection(
          userId: widget.userId,
          role: _user!.role,
          selected: _selected,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions saved')),
      );
      context.pop();
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppShell(
        title: 'Permissions',
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) {
      return const AppShell(
        title: 'Permissions',
        child: Center(child: Text('User not found')),
      );
    }

    return AppShell(
      title: 'Permissions — ${_user!.fullName}',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: AdvancedPermissionPanel(
                    selected: _selected,
                    initialRole: _user!.role,
                    onChanged: (v) => setState(() => _selected = v),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save permissions',
                  loading: _saving,
                  expand: true,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
