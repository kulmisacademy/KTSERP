import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../auth/application/session_provider.dart';
import '../../auth/domain/app_role.dart';
import '../domain/permission_service.dart';

/// Live permission checker for the signed-in user.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  ref.watch(sessionProvider);
  return StoreContext.permissionChecker;
});

/// Current signed-in staff role (store scope).
final currentUserRoleProvider = Provider<AppRole>((ref) {
  ref.watch(sessionProvider);
  return StoreContext.role;
});

final canPermissionProvider = Provider.family<bool, String>((ref, permission) {
  return ref.watch(permissionServiceProvider).has(permission);
});
