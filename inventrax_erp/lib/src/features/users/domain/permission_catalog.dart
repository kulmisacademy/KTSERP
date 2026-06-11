import '../../auth/domain/app_role.dart';
import 'permission_registry.dart';

export 'permission_registry.dart' show InventraxPermissionRegistry, PermissionEntry, PermissionTemplates, PermAction, SidebarNavEntry;

/// @deprecated Use [InventraxPermissionRegistry.allEntries].
List<PermissionEntry> get kPermissionCatalog => InventraxPermissionRegistry.allEntries;

Set<String> defaultPermissionsForRole(AppRole role) =>
    InventraxPermissionRegistry.templateForRole(role);
