import '../../../core/store_context.dart';
import 'app_permission.dart';
import 'permission_service.dart';

/// Enterprise RBAC helpers — use in UI, routes, and action guards.
class Rbac {
  Rbac._();

  static PermissionService get _p => StoreContext.permissionChecker;

  static bool can(String permission) => _p.has(permission);

  // Products
  static bool canViewProducts() => can(AppPermission.productsView);
  static bool canCreateProducts() => can(AppPermission.productsCreate);
  static bool canEditProducts() => can(AppPermission.productsEdit);
  static bool canDeleteProducts() => can(AppPermission.productsDelete);

  // Sales / POS
  static bool canUsePos() => can(AppPermission.posView);
  static bool canCreateSales() => can(AppPermission.salesCreate);
  static bool canRefundSales() => can(AppPermission.salesRefund);

  // Purchases
  static bool canViewPurchases() => can(AppPermission.purchasesView);
  static bool canCreatePurchases() => can(AppPermission.purchasesCreate);

  // Accounting
  static bool canViewAccounting() => can(AppPermission.accountingView);
  static bool canManageAccounting() => can(AppPermission.accountingManage);

  // Users & settings
  static bool canManageUsers() => can(AppPermission.usersManage);
  static bool canViewUsers() => can(AppPermission.usersView);
  static bool canManageSettings() => can(AppPermission.settingsManage);
  static bool canManageSubscription() => can(AppPermission.subscriptionManage);

  // Reports
  static bool canViewReports() => can(AppPermission.reportsView);

  // Inventory
  static bool canManageInventory() => can(AppPermission.inventoryManage);
}
