import 'package:inventrax_erp/l10n/app_localizations.dart';

/// Maps sidebar routes to localized labels (fallback: English ARB).
String localizedNavLabel(AppLocalizations l10n, String route) {
  return switch (route) {
    '/dashboard' => l10n.navDashboard,
    '/pos' => l10n.navPos,
    '/sales/custom' => l10n.navCustomSales,
    '/sales/drafts' => l10n.navDraftInvoices,
    '/sales' => l10n.navSalesHistory,
    '/products' => l10n.navProducts,
    '/categories' => l10n.navCategories,
    '/brands' => l10n.navBrands,
    '/inventory' => l10n.navInventory,
    '/purchases' => l10n.navPurchaseHistory,
    '/purchases/add' => l10n.navReceiveStock,
    '/customers' => l10n.navCustomers,
    '/suppliers' => l10n.navSuppliers,
    '/debts' => l10n.navDebts,
    '/expenses' => l10n.navExpenses,
    '/accounting' => l10n.navAccounting,
    '/reports' => l10n.navReports,
    '/ai-insights' => l10n.navAiInsights,
    '/notifications' => l10n.navNotifications,
    '/sync' => l10n.navSync,
    '/users' => l10n.navUserManagement,
    '/settings' => l10n.navSettings,
    _ => route,
  };
}

String localizedPageTitle(AppLocalizations l10n, String route) =>
    localizedNavLabel(l10n, route);
