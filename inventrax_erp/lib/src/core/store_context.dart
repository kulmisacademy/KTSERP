import '../features/auth/domain/app_role.dart';
import '../features/users/domain/permission_service.dart';

/// Active tenant/store for the signed-in session.
class StoreContext {
  const StoreContext._();

  static const defaultTenantId = 'dev-tenant';
  static const defaultStoreId = 'dev-store';

  static String tenantId = defaultTenantId;
  static String storeId = defaultStoreId;
  static String? userId;
  static String? userEmail;
  static String? displayName;
  static String? storeName;
  static AppRole role = AppRole.cashier;
  static Set<String> permissions = {};

  static PermissionService get permissionChecker =>
      PermissionService(permissions);

  static bool can(String permission) => permissionChecker.has(permission);

  static void apply({
    required String tenantId,
    required String storeId,
    String? userId,
    String? email,
    String? displayName,
    String? storeName,
    AppRole role = AppRole.cashier,
    Set<String>? permissions,
  }) {
    StoreContext.tenantId = tenantId;
    StoreContext.storeId = storeId;
    StoreContext.userId = userId;
    StoreContext.userEmail = email;
    StoreContext.displayName = displayName;
    StoreContext.storeName = storeName;
    StoreContext.role = role;
    if (permissions != null) {
      StoreContext.permissions = permissions;
    }
  }

  static void reset() {
    tenantId = defaultTenantId;
    storeId = defaultStoreId;
    userId = null;
    userEmail = null;
    displayName = null;
    storeName = null;
    role = AppRole.cashier;
    permissions = {};
  }

  static bool get isLoggedIn => userEmail != null;
  static bool get isSuperAdmin => role == AppRole.superAdmin;
  static bool get isStoreOwner => role == AppRole.storeOwner || isSuperAdmin;
}
