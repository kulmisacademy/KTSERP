import 'permission_registry.dart';

/// Convenience accessors — canonical ids live in [InventraxPermissionRegistry].
class AppPermission {
  AppPermission._();

  static String _p(String m, String p, PermAction a) =>
      InventraxPermissionRegistry.permissionId(m, p, a);

  static String get dashboardView => _p('dashboard', 'main', PermAction.view);

  static String get posView => _p('pos', 'terminal', PermAction.view);
  static String get posCheckout => posView;
  static String get posCreate => _p('pos', 'terminal', PermAction.create);

  static String get salesView => _p('sales', 'history', PermAction.view);
  static String get salesCreate => _p('sales', 'history', PermAction.create);
  static String get salesRefund => _p('sales', 'history', PermAction.refund);

  static String get productsView => _p('products', 'catalog', PermAction.view);
  static String get productsCreate => _p('products', 'catalog', PermAction.create);
  static String get productsEdit => _p('products', 'catalog', PermAction.edit);
  static String get productsDelete => _p('products', 'catalog', PermAction.delete);

  static String get categoriesView => _p('products', 'categories', PermAction.view);
  static String get categoriesCreate => _p('products', 'categories', PermAction.create);
  static String get brandsView => _p('products', 'brands', PermAction.view);
  static String get brandsCreate => _p('products', 'brands', PermAction.create);

  static String get inventoryView => _p('inventory', 'stock', PermAction.view);
  static String get inventoryManage => _p('inventory', 'stock', PermAction.manage);

  static String get purchasesView => _p('purchases', 'history', PermAction.view);
  static String get purchasesCreate => _p('purchases', 'create', PermAction.create);

  static String get customersView => _p('customers', 'directory', PermAction.view);
  static String get customersCreate => _p('customers', 'directory', PermAction.create);

  static String get suppliersView => _p('suppliers', 'directory', PermAction.view);

  static String get debtsView => _p('debts', 'ledger', PermAction.view);

  static String get expensesView => _p('expenses', 'list', PermAction.view);

  static String get accountingView => _p('accounting', 'dashboard', PermAction.view);
  static String get accountingManage => _p('accounting', 'journals', PermAction.create);

  static String get reportsView => _p('reports', 'main', PermAction.view);
  static String get aiInsightsView => _p('reports', 'ai', PermAction.view);

  static String get notificationsView => _p('notifications', 'inbox', PermAction.view);
  static String get syncView => _p('sync', 'queue', PermAction.view);

  static String get usersView => _p('users', 'directory', PermAction.view);
  static String get usersManage => _p('users', 'directory', PermAction.create);
  static String get usersPermissions => _p('users', 'permissions', PermAction.manage);

  static String get settingsView => _p('settings', 'store', PermAction.view);
  static String get settingsManage => _p('settings', 'store', PermAction.manage);
  static String get systemHealthView => _p('settings', 'health', PermAction.view);

  static String get subscriptionView => _p('subscription', 'plan', PermAction.view);
  static String get subscriptionManage => _p('subscription', 'plan', PermAction.manage);

  static String? forRoute(String path) =>
      InventraxPermissionRegistry.permissionForRoute(path);
}
