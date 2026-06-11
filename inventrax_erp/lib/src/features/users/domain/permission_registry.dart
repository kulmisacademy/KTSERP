import 'package:flutter/material.dart';

import '../../auth/domain/app_role.dart';

/// Supported permission actions (PRD §8).
enum PermAction {
  view('view', 'View'),
  create('create', 'Create'),
  edit('edit', 'Edit'),
  delete('delete', 'Delete'),
  export('export', 'Export'),
  import('import', 'Import'),
  approve('approve', 'Approve'),
  print('print', 'Print'),
  refund('refund', 'Refund'),
  manage('manage', 'Manage'),
  receive('receive', 'Receive payment');

  const PermAction(this.key, this.label);
  final String key;
  final String label;
}

/// Single assignable permission (page or action).
class PermissionEntry {
  const PermissionEntry({
    required this.id,
    required this.moduleId,
    required this.pageId,
    required this.action,
    required this.label,
    this.description,
    this.route,
    this.sortOrder = 0,
    this.isPageGate = false,
  });

  final String id;
  final String moduleId;
  final String pageId;
  final PermAction action;
  final String label;
  final String? description;
  final String? route;
  final int sortOrder;

  /// When true, granting this permission shows the page in sidebar / allows route.
  final bool isPageGate;

  String get moduleName => InventraxPermissionRegistry.moduleName(moduleId);
}

class PermissionPageDef {
  const PermissionPageDef({
    required this.id,
    required this.label,
    this.route,
    this.sidebarLabel,
    this.sidebarIcon,
    this.actions = const [PermAction.view],
    this.extraActions = const [],
  });

  final String id;
  final String label;
  final String? route;
  final String? sidebarLabel;
  final IconData? sidebarIcon;
  final List<PermAction> actions;
  final List<PermAction> extraActions;

  List<PermAction> get allActions => [...actions, ...extraActions];
}

class PermissionModuleDef {
  const PermissionModuleDef({
    required this.id,
    required this.name,
    required this.pages,
    this.icon = Icons.folder_outlined,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final IconData icon;
  final int sortOrder;
  final List<PermissionPageDef> pages;
}

/// Central permission catalog — add modules/pages here; UI and routes read from this.
class InventraxPermissionRegistry {
  InventraxPermissionRegistry._();

  static const modules = <PermissionModuleDef>[
    PermissionModuleDef(
      id: 'dashboard',
      name: 'Dashboard',
      icon: Icons.dashboard_outlined,
      sortOrder: 10,
      pages: [
        PermissionPageDef(
          id: 'main',
          label: 'Dashboard',
          route: '/dashboard',
          sidebarLabel: 'Dashboard',
          sidebarIcon: Icons.dashboard_outlined,
          actions: [PermAction.view],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'pos',
      name: 'POS',
      icon: Icons.point_of_sale_outlined,
      sortOrder: 20,
      pages: [
        PermissionPageDef(
          id: 'terminal',
          label: 'POS Terminal',
          route: '/pos',
          sidebarLabel: 'POS',
          sidebarIcon: Icons.point_of_sale_outlined,
          actions: [PermAction.view],
          extraActions: [
            PermAction.create,
            PermAction.edit,
            PermAction.delete,
            PermAction.refund,
            PermAction.print,
            PermAction.manage, // hold sale, override price
          ],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'custom_sales',
      name: 'Custom Sales',
      icon: Icons.description_outlined,
      sortOrder: 25,
      pages: [
        PermissionPageDef(
          id: 'builder',
          label: 'Custom sales',
          route: '/sales/custom',
          sidebarLabel: 'Custom Sales',
          sidebarIcon: Icons.description_outlined,
          actions: [PermAction.view, PermAction.create],
          extraActions: [
            PermAction.edit,
            PermAction.print,
            PermAction.export,
          ],
        ),
        PermissionPageDef(
          id: 'drafts',
          label: 'Draft invoices',
          route: '/sales/drafts',
          sidebarLabel: 'Draft Invoices',
          sidebarIcon: Icons.drafts_outlined,
          actions: [PermAction.view],
          extraActions: [
            PermAction.create,
            PermAction.edit,
            PermAction.delete,
          ],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'sales',
      name: 'Sales',
      icon: Icons.receipt_outlined,
      sortOrder: 30,
      pages: [
        PermissionPageDef(
          id: 'history',
          label: 'Sales history',
          route: '/sales',
          sidebarLabel: 'Sales History',
          sidebarIcon: Icons.receipt_long_outlined,
          actions: [PermAction.view],
          extraActions: [
            PermAction.create,
            PermAction.edit,
            PermAction.delete,
            PermAction.refund,
            PermAction.export,
            PermAction.print,
          ],
        ),
        PermissionPageDef(
          id: 'receipt',
          label: 'Sale receipt preview',
          actions: [PermAction.view, PermAction.print],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'products',
      name: 'Products',
      icon: Icons.inventory_2_outlined,
      sortOrder: 40,
      pages: [
        PermissionPageDef(
          id: 'catalog',
          label: 'Product list',
          route: '/products',
          sidebarLabel: 'Products',
          sidebarIcon: Icons.inventory_2_outlined,
          actions: [PermAction.view],
          extraActions: [
            PermAction.create,
            PermAction.edit,
            PermAction.delete,
            PermAction.import,
            PermAction.export,
            PermAction.print,
          ],
        ),
        PermissionPageDef(
          id: 'categories',
          label: 'Categories',
          route: '/categories',
          sidebarLabel: 'Categories',
          sidebarIcon: Icons.category_outlined,
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
        PermissionPageDef(
          id: 'brands',
          label: 'Brands',
          route: '/brands',
          sidebarLabel: 'Brands',
          sidebarIcon: Icons.branding_watermark_outlined,
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
        PermissionPageDef(
          id: 'barcode',
          label: 'Barcode labels',
          actions: [PermAction.view, PermAction.print],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'inventory',
      name: 'Inventory',
      icon: Icons.warehouse_outlined,
      sortOrder: 50,
      pages: [
        PermissionPageDef(
          id: 'stock',
          label: 'Inventory & adjustments',
          route: '/inventory',
          sidebarLabel: 'Inventory',
          sidebarIcon: Icons.warehouse_outlined,
          actions: [PermAction.view, PermAction.edit, PermAction.manage],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'purchases',
      name: 'Purchases',
      icon: Icons.shopping_bag_outlined,
      sortOrder: 60,
      pages: [
        PermissionPageDef(
          id: 'history',
          label: 'Purchase history',
          route: '/purchases',
          sidebarLabel: 'Purchases',
          sidebarIcon: Icons.shopping_bag_outlined,
          actions: [PermAction.view],
          extraActions: [PermAction.edit, PermAction.delete, PermAction.export],
        ),
        PermissionPageDef(
          id: 'create',
          label: 'Add purchase',
          route: '/purchases/add',
          sidebarLabel: 'Add Purchase',
          sidebarIcon: Icons.add_shopping_cart,
          actions: [PermAction.view, PermAction.create],
        ),
        PermissionPageDef(
          id: 'detail',
          label: 'Purchase detail',
          actions: [PermAction.view, PermAction.edit],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'customers',
      name: 'Customers',
      icon: Icons.people_outline,
      sortOrder: 70,
      pages: [
        PermissionPageDef(
          id: 'directory',
          label: 'Customer directory',
          route: '/customers',
          sidebarLabel: 'Customers',
          sidebarIcon: Icons.people_outline,
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'suppliers',
      name: 'Suppliers',
      icon: Icons.local_shipping_outlined,
      sortOrder: 80,
      pages: [
        PermissionPageDef(
          id: 'directory',
          label: 'Supplier directory',
          route: '/suppliers',
          sidebarLabel: 'Suppliers',
          sidebarIcon: Icons.local_shipping_outlined,
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'debts',
      name: 'Debts',
      icon: Icons.request_quote_outlined,
      sortOrder: 90,
      pages: [
        PermissionPageDef(
          id: 'ledger',
          label: 'Debts overview',
          route: '/debts',
          sidebarLabel: 'Debts',
          sidebarIcon: Icons.request_quote_outlined,
          actions: [PermAction.view],
          extraActions: [
            PermAction.create,
            PermAction.edit,
            PermAction.delete,
            PermAction.receive,
            PermAction.export,
          ],
        ),
        PermissionPageDef(
          id: 'customer_profile',
          label: 'Customer debt profile',
          actions: [PermAction.view, PermAction.edit, PermAction.receive],
        ),
        PermissionPageDef(
          id: 'supplier_profile',
          label: 'Supplier debt profile',
          actions: [PermAction.view, PermAction.edit, PermAction.receive],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'expenses',
      name: 'Expenses',
      icon: Icons.receipt_long_outlined,
      sortOrder: 100,
      pages: [
        PermissionPageDef(
          id: 'list',
          label: 'Expenses',
          route: '/expenses',
          sidebarLabel: 'Expenses',
          sidebarIcon: Icons.receipt_long_outlined,
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete, PermAction.export],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'accounting',
      name: 'Accounting',
      icon: Icons.calculate_outlined,
      sortOrder: 110,
      pages: [
        PermissionPageDef(
          id: 'dashboard',
          label: 'Accounting home',
          route: '/accounting',
          sidebarLabel: 'Accounting',
          sidebarIcon: Icons.calculate_outlined,
          actions: [PermAction.view],
        ),
        PermissionPageDef(
          id: 'chart',
          label: 'Chart of accounts',
          route: '/accounting/chart',
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
        PermissionPageDef(
          id: 'journals',
          label: 'Journal entries',
          route: '/accounting/journals',
          actions: [PermAction.view, PermAction.create, PermAction.edit, PermAction.delete],
        ),
        PermissionPageDef(
          id: 'journal_new',
          label: 'New journal entry',
          route: '/accounting/journals/new',
          actions: [PermAction.view, PermAction.create],
        ),
        PermissionPageDef(
          id: 'ledger',
          label: 'General ledger',
          route: '/accounting/ledger',
          actions: [PermAction.view, PermAction.export],
        ),
        PermissionPageDef(
          id: 'cash',
          label: 'Deposits & withdrawals',
          route: '/accounting/cash',
          actions: [PermAction.view, PermAction.create, PermAction.manage],
        ),
        PermissionPageDef(
          id: 'payment_accounts',
          label: 'Payment accounts',
          route: '/accounting/payment-accounts',
          actions: [PermAction.view, PermAction.manage],
        ),
        PermissionPageDef(
          id: 'trial_balance',
          label: 'Trial balance',
          route: '/accounting/reports/trial-balance',
          actions: [PermAction.view, PermAction.export],
        ),
        PermissionPageDef(
          id: 'profit_loss',
          label: 'Profit & loss',
          route: '/accounting/reports/profit-loss',
          actions: [PermAction.view, PermAction.export],
        ),
        PermissionPageDef(
          id: 'balance_sheet',
          label: 'Balance sheet',
          route: '/accounting/reports/balance-sheet',
          actions: [PermAction.view, PermAction.export],
        ),
        PermissionPageDef(
          id: 'cash_flow',
          label: 'Cash flow',
          route: '/accounting/reports/cash-flow',
          actions: [PermAction.view, PermAction.export],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'reports',
      name: 'Reports',
      icon: Icons.analytics_outlined,
      sortOrder: 120,
      pages: [
        PermissionPageDef(
          id: 'main',
          label: 'Business reports',
          route: '/reports',
          sidebarLabel: 'Reports',
          sidebarIcon: Icons.analytics_outlined,
          actions: [PermAction.view, PermAction.export],
        ),
        PermissionPageDef(
          id: 'ai',
          label: 'AI Insights',
          route: '/ai-insights',
          sidebarLabel: 'AI Insights',
          sidebarIcon: Icons.auto_awesome,
          actions: [PermAction.view],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'notifications',
      name: 'Notifications',
      icon: Icons.notifications_outlined,
      sortOrder: 130,
      pages: [
        PermissionPageDef(
          id: 'inbox',
          label: 'Notifications',
          route: '/notifications',
          sidebarLabel: 'Notifications',
          sidebarIcon: Icons.notifications_outlined,
          actions: [PermAction.view, PermAction.manage],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'sync',
      name: 'Sync',
      icon: Icons.sync_outlined,
      sortOrder: 140,
      pages: [
        PermissionPageDef(
          id: 'queue',
          label: 'Sync queue',
          route: '/sync',
          sidebarLabel: 'Sync',
          sidebarIcon: Icons.sync_outlined,
          actions: [PermAction.view, PermAction.manage],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'users',
      name: 'Users',
      icon: Icons.manage_accounts_outlined,
      sortOrder: 150,
      pages: [
        PermissionPageDef(
          id: 'directory',
          label: 'User management',
          route: '/users',
          sidebarLabel: 'User Management',
          sidebarIcon: Icons.manage_accounts_outlined,
          actions: [PermAction.view],
          extraActions: [PermAction.create, PermAction.edit, PermAction.delete, PermAction.manage],
        ),
        PermissionPageDef(
          id: 'create',
          label: 'Create user',
          route: '/users/create',
          actions: [PermAction.view, PermAction.create],
        ),
        PermissionPageDef(
          id: 'permissions',
          label: 'Edit permissions',
          actions: [PermAction.view, PermAction.manage],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'settings',
      name: 'Settings',
      icon: Icons.settings_outlined,
      sortOrder: 160,
      pages: [
        PermissionPageDef(
          id: 'store',
          label: 'Store settings',
          route: '/settings',
          sidebarLabel: 'Settings',
          sidebarIcon: Icons.settings_outlined,
          actions: [PermAction.view, PermAction.edit, PermAction.manage],
        ),
        PermissionPageDef(
          id: 'health',
          label: 'System health',
          route: '/settings/health',
          actions: [PermAction.view, PermAction.manage],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'audit',
      name: 'Audit logs',
      icon: Icons.history,
      sortOrder: 170,
      pages: [
        PermissionPageDef(
          id: 'logs',
          label: 'Audit & activity logs',
          actions: [PermAction.view, PermAction.export],
        ),
      ],
    ),
    PermissionModuleDef(
      id: 'subscription',
      name: 'Subscription',
      icon: Icons.card_membership_outlined,
      sortOrder: 180,
      pages: [
        PermissionPageDef(
          id: 'plan',
          label: 'Subscription & billing',
          route: '/billing',
          actions: [PermAction.view, PermAction.manage],
        ),
      ],
    ),
  ];

  static final List<PermissionEntry> allEntries = _buildEntries();
  static final Map<String, PermissionEntry> byId = {
    for (final e in allEntries) e.id: e,
  };
  static final Map<String, String> routeToPermission = _buildRouteMap();
  static final List<SidebarNavEntry> sidebarNav = _buildSidebar();

  static String moduleName(String moduleId) {
    return modules
        .firstWhere((m) => m.id == moduleId, orElse: () => modules.first)
        .name;
  }

  static String permissionId(String moduleId, String pageId, PermAction action) =>
      '$moduleId.$pageId.${action.key}';

  static List<PermissionEntry> _buildEntries() {
    final out = <PermissionEntry>[];
    var order = 0;
    for (final mod in modules) {
      for (final page in mod.pages) {
        for (final action in page.allActions) {
          final id = permissionId(mod.id, page.id, action);
          final isPageGate = action == PermAction.view;
          out.add(
            PermissionEntry(
              id: id,
              moduleId: mod.id,
              pageId: page.id,
              action: action,
              label: _actionLabel(page.label, action),
              route: isPageGate ? page.route : null,
              sortOrder: order++,
              isPageGate: isPageGate && page.route != null,
            ),
          );
        }
      }
    }
    return out;
  }

  static String _actionLabel(String pageLabel, PermAction action) {
    if (action == PermAction.view) return 'View $pageLabel';
    return '${action.label} — $pageLabel';
  }

  static Map<String, String> _buildRouteMap() {
    final map = <String, String>{};
    for (final e in allEntries) {
      if (e.route != null && e.isPageGate) {
        map[e.route!] = e.id;
      }
    }
    return map;
  }

  static List<SidebarNavEntry> _buildSidebar() {
    final items = <SidebarNavEntry>[];
    for (final mod in modules) {
      for (final page in mod.pages) {
        if (page.route == null || page.sidebarLabel == null) continue;
        final perm = permissionId(mod.id, page.id, PermAction.view);
        items.add(
          SidebarNavEntry(
            label: page.sidebarLabel!,
            route: page.route!,
            permissionId: perm,
            icon: page.sidebarIcon ?? mod.icon,
            moduleId: mod.id,
          ),
        );
      }
    }
    return items;
  }

  /// Longest-prefix route match for guards.
  static String? permissionForRoute(String path) {
    if (routeToPermission.containsKey(path)) {
      return routeToPermission[path];
    }
    String? best;
    var bestLen = -1;
    for (final entry in routeToPermission.entries) {
      if (path == entry.key || path.startsWith('${entry.key}/')) {
        if (entry.key.length > bestLen) {
          bestLen = entry.key.length;
          best = entry.value;
        }
      }
    }
    return best;
  }

  static Set<String> allPermissionIds() => allEntries.map((e) => e.id).toSet();

  static Set<String> templateForRole(AppRole role) {
    switch (role) {
      case AppRole.superAdmin:
      case AppRole.storeOwner:
        return {...allPermissionIds(), '*'};
      case AppRole.admin:
        return _explicitTemplate([
          'dashboard.main.view',
          'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.edit',
          'pos.terminal.print', 'pos.terminal.refund', 'pos.terminal.manage',
          'custom_sales.builder.view', 'custom_sales.builder.create',
          'custom_sales.builder.edit', 'custom_sales.builder.print',
          'custom_sales.drafts.view', 'custom_sales.drafts.create',
          'custom_sales.drafts.edit',
          'sales.history.view', 'sales.history.create', 'sales.history.edit',
          'sales.history.refund', 'sales.history.export', 'sales.history.print',
          'products.catalog.view', 'products.catalog.create', 'products.catalog.edit',
          'products.catalog.delete', 'products.catalog.import', 'products.catalog.export',
          'products.categories.view', 'products.categories.create', 'products.categories.edit',
          'products.brands.view', 'products.brands.create', 'products.brands.edit',
          'inventory.stock.view', 'inventory.stock.edit', 'inventory.stock.manage',
          'purchases.history.view', 'purchases.history.edit', 'purchases.history.export',
          'purchases.create.view', 'purchases.create.create',
          'customers.directory.view', 'customers.directory.create',
          'customers.directory.edit', 'customers.directory.delete',
          'suppliers.directory.view', 'suppliers.directory.create',
          'suppliers.directory.edit', 'suppliers.directory.delete',
          'debts.ledger.view', 'debts.ledger.receive', 'debts.ledger.export',
          'expenses.list.view',
          'reports.main.view', 'reports.main.export',
          'notifications.inbox.view',
          'sync.queue.view',
          'settings.store.view',
        ]);
      case AppRole.manager:
        return _explicitTemplate([
          ...templateForRole(AppRole.admin),
          'debts.ledger.create', 'debts.ledger.edit',
          'expenses.list.create', 'expenses.list.edit', 'expenses.list.export',
          'users.directory.view',
          'audit.logs.view',
        ]);
      case AppRole.cashier:
        return _explicitTemplate([
          'dashboard.main.view',
          'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.print',
          'pos.terminal.manage',
          'custom_sales.builder.view', 'custom_sales.builder.create',
          'custom_sales.builder.print',
          'custom_sales.drafts.view', 'custom_sales.drafts.create',
          'custom_sales.drafts.edit',
          'sales.history.view', 'sales.history.create', 'sales.history.print',
          'customers.directory.view', 'customers.directory.create',
          'customers.directory.edit',
          'notifications.inbox.view',
        ]);
      case AppRole.sales:
        return _explicitTemplate([
          'dashboard.main.view',
          'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.print',
          'pos.terminal.manage',
          'custom_sales.builder.view', 'custom_sales.builder.create',
          'custom_sales.builder.edit', 'custom_sales.builder.print',
          'custom_sales.drafts.view', 'custom_sales.drafts.create',
          'custom_sales.drafts.edit',
          'sales.history.view', 'sales.history.create', 'sales.history.edit',
          'sales.history.print', 'sales.history.export',
          'customers.directory.view', 'customers.directory.create',
          'customers.directory.edit',
          'notifications.inbox.view',
        ]);
      case AppRole.accountant:
        return _explicitTemplate([
          'dashboard.main.view',
          'custom_sales.builder.view', 'custom_sales.builder.create',
          'custom_sales.builder.edit', 'custom_sales.builder.print',
          'custom_sales.drafts.view', 'custom_sales.drafts.create',
          'custom_sales.drafts.edit',
          'sales.history.view', 'sales.history.print', 'sales.history.export',
          'debts.ledger.view', 'debts.ledger.create', 'debts.ledger.edit',
          'debts.ledger.receive', 'debts.ledger.export',
          'debts.customer_profile.view', 'debts.customer_profile.edit',
          'debts.customer_profile.receive',
          'debts.supplier_profile.view', 'debts.supplier_profile.edit',
          'debts.supplier_profile.receive',
          'expenses.list.view', 'expenses.list.create', 'expenses.list.edit',
          'expenses.list.delete', 'expenses.list.export',
          'accounting.dashboard.view', 'accounting.chart.view',
          'accounting.journals.view', 'accounting.journals.create',
          'accounting.journal_new.view', 'accounting.journal_new.create',
          'accounting.ledger.view', 'accounting.cash.view',
          'accounting.cash.create', 'accounting.payment_accounts.view',
          'accounting.payment_accounts.create', 'accounting.trial_balance.view',
          'accounting.profit_loss.view', 'accounting.balance_sheet.view',
          'accounting.cash_flow.view',
          'reports.main.view', 'reports.main.export',
          'notifications.inbox.view',
        ]);
      case AppRole.inventoryStaff:
        return _explicitTemplate([
          'dashboard.main.view',
          'products.catalog.view', 'products.catalog.create', 'products.catalog.edit',
          'products.catalog.delete', 'products.catalog.import', 'products.catalog.print',
          'products.categories.view', 'products.categories.create',
          'products.categories.edit', 'products.categories.delete',
          'products.brands.view', 'products.brands.create',
          'products.brands.edit', 'products.brands.delete',
          'products.barcode.view', 'products.barcode.print',
          'inventory.stock.view', 'inventory.stock.edit', 'inventory.stock.manage',
          'suppliers.directory.view', 'suppliers.directory.create',
          'suppliers.directory.edit', 'suppliers.directory.delete',
          'purchases.history.view', 'purchases.history.edit', 'purchases.history.export',
          'purchases.create.view', 'purchases.create.create',
          'purchases.detail.view', 'purchases.detail.edit',
          'notifications.inbox.view',
          'sync.queue.view', 'sync.queue.manage',
        ]);
      case AppRole.reports:
        return _explicitTemplate([
          'dashboard.main.view',
          'reports.main.view', 'reports.main.export',
          'reports.ai.view',
          'notifications.inbox.view',
        ]);
    }
  }

  static Set<String> _explicitTemplate(Iterable<String> ids) {
    final valid = allPermissionIds();
    return {for (final id in ids) if (valid.contains(id)) id};
  }

  /// Legacy alias map (old flat ids → new ids) for DB migration compatibility.
  static const legacyAliases = <String, String>{
    'dashboard.view': 'dashboard.main.view',
    'pos.checkout': 'pos.terminal.view',
    'pos.hold_sale': 'pos.terminal.manage',
    'pos.override_price': 'pos.terminal.manage',
    'sales.view': 'sales.history.view',
    'sales.create': 'sales.history.create',
    'sales.delete': 'sales.history.delete',
    'sales.refund': 'sales.history.refund',
    'products.view': 'products.catalog.view',
    'products.create': 'products.catalog.create',
    'products.edit': 'products.catalog.edit',
    'products.delete': 'products.catalog.delete',
    'categories.manage': 'products.categories.manage',
    'inventory.view': 'inventory.stock.view',
    'inventory.adjust': 'inventory.stock.manage',
    'purchases.view': 'purchases.history.view',
    'purchases.create': 'purchases.create.create',
    'customers.manage': 'customers.directory.manage',
    'suppliers.manage': 'suppliers.directory.manage',
    'debts.view': 'debts.ledger.view',
    'debts.manage': 'debts.ledger.receive',
    'expenses.view': 'expenses.list.view',
    'expenses.manage': 'expenses.list.create',
    'accounting.view': 'accounting.dashboard.view',
    'accounting.manage': 'accounting.journals.create',
    'reports.view': 'reports.main.view',
    'reports.export': 'reports.main.export',
    'notifications.view': 'notifications.inbox.view',
    'sync.view': 'sync.queue.view',
    'settings.view': 'settings.store.view',
    'settings.manage': 'settings.store.manage',
    'users.view': 'users.directory.view',
    'users.manage': 'users.directory.create',
    'users.permissions': 'users.permissions.manage',
  };

  static Set<String> normalizeGrants(Iterable<String> raw) {
    final out = <String>{};
    for (final g in raw) {
      if (g == '*' || g == 'store.*') {
        out.add('*');
        continue;
      }
      final alias = legacyAliases[g];
      if (alias != null) {
        out.add(alias);
        out.add(g);
      } else {
        out.add(g);
      }
      if (g.contains('.*')) {
        final prefix = g.substring(0, g.length - 2);
        for (final e in allEntries) {
          if (e.id.startsWith('$prefix.')) out.add(e.id);
        }
      }
    }
    return out;
  }
}

class SidebarNavEntry {
  const SidebarNavEntry({
    required this.label,
    required this.route,
    required this.permissionId,
    required this.icon,
    required this.moduleId,
  });

  final String label;
  final String route;
  final String permissionId;
  final IconData icon;
  final String moduleId;
}

/// Role permission templates (PRD §9).
class PermissionTemplates {
  static const labels = <AppRole, String>{
    AppRole.admin: 'Admin — operations (no billing/users)',
    AppRole.manager: 'Manager — operations + staff view',
    AppRole.cashier: 'Cashier — POS only',
    AppRole.sales: 'Sales — POS, invoices, customers',
    AppRole.accountant: 'Accounting — finance & reports',
    AppRole.inventoryStaff: 'Inventory — stock & purchases',
    AppRole.reports: 'Reports — read-only analytics',
    AppRole.storeOwner: 'Owner (full access)',
  };

  static Set<String> forRole(AppRole role) =>
      InventraxPermissionRegistry.templateForRole(role);
}
