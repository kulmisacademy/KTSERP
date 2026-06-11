import 'permission_registry.dart';

/// Evaluates RBAC grants including wildcards and legacy permission aliases.
class PermissionService {
  PermissionService(Iterable<String> grants)
      : _grants = InventraxPermissionRegistry.normalizeGrants(grants);

  final Set<String> _grants;

  bool has(String permission) {
    if (_grants.contains('*') || _grants.contains('store.*')) return true;
    final normalized = InventraxPermissionRegistry.legacyAliases[permission] ?? permission;
    if (_grants.contains(permission) || _grants.contains(normalized)) return true;

    for (final g in _grants) {
      if (_matchesWildcard(g, permission) || _matchesWildcard(g, normalized)) {
        return true;
      }
    }
    return false;
  }

  bool canAccessRoute(String path) {
    final required = InventraxPermissionRegistry.permissionForRoute(path);
    if (required == null) return true;
    return has(required);
  }

  bool hasAny(Iterable<String> permissions) => permissions.any(has);

  bool hasAll(Iterable<String> permissions) => permissions.every(has);

  static bool _matchesWildcard(String grant, String required) {
    if (!grant.endsWith('.*')) return false;
    final prefix = grant.substring(0, grant.length - 2);
    return required == prefix || required.startsWith('$prefix.');
  }

  static Set<String> parseList(Iterable<dynamic>? raw) {
    if (raw == null) return {};
    return InventraxPermissionRegistry.normalizeGrants(
      raw.map((e) => e.toString()).where((s) => s.isNotEmpty),
    );
  }
}
