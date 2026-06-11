import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/components/app_button.dart';
import '../../../ui/components/app_card.dart';
import '../../../ui/components/app_input.dart';
import '../../../ui/layout/app_shell.dart';
import '../../auth/application/password_validator.dart' show PasswordValidator;
import '../../auth/domain/app_role.dart';
import '../../platform/application/plan_limits_service.dart';
import '../application/users_repository.dart';
import '../domain/permission_registry.dart';
import 'widgets/advanced_permission_panel.dart';

class CreateUserPage extends ConsumerStatefulWidget {
  const CreateUserPage({super.key});

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  AppRole _role = AppRole.cashier;
  String _status = 'active';
  late Set<String> _permissions = PermissionTemplates.forRole(AppRole.cashier);
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onRoleChanged(AppRole role) {
    setState(() {
      _role = role;
      _permissions = PermissionTemplates.forRole(role);
    });
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    final pwd = PasswordValidator.validate(_password.text);
    if (!pwd.isValid) {
      setState(() {
        _error = pwd.message;
        _saving = false;
      });
      return;
    }
    try {
      final users = await ref.read(storeUsersProvider.future);
      final limit = await ref.read(planLimitsServiceProvider).checkCanAddUser(users.length);
      if (!limit.allowed) {
        setState(() {
          _error = limit.message;
          _saving = false;
        });
        return;
      }
      await ref.read(usersRepositoryProvider).createUser(
            fullName: _name.text,
            email: _email.text,
            phone: _phone.text,
            password: _password.text,
            role: _role,
            status: _status,
            permissionGrants: _permissions,
          );
      ref.invalidate(storeUsersProvider);
      if (mounted) context.go('/users');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Create user',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildPermissionsCard(),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Create user',
                  loading: _saving,
                  expand: true,
                  onPressed: _saving ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          AppInput(controller: _name, label: 'Full name'),
          const SizedBox(height: 12),
          AppInput(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppInput(
            controller: _phone,
            label: 'Phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppInput(
            controller: _password,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AppRole>(
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final r in AppRole.assignableRoles)
                DropdownMenuItem(value: r, child: Text(r.label)),
            ],
            onChanged: (v) {
              if (v != null) _onRoleChanged(v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _status = v);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Permissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Expand each module and page to set access. Role template pre-fills toggles.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          AdvancedPermissionPanel(
            selected: _permissions,
            initialRole: _role,
            onChanged: (v) => setState(() => _permissions = v),
          ),
        ],
      ),
    );
  }
}
