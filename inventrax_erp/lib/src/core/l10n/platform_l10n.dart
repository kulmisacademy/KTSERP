import 'package:inventrax_erp/l10n/app_localizations.dart';

String localizedPlatformNavLabel(AppLocalizations l10n, String path) {
  return switch (path) {
    '/platform/dashboard' => l10n.platformNavDashboard,
    '/platform/search' => l10n.platformNavGlobalSearch,
    '/platform/stores' => l10n.platformNavAllStores,
    '/platform/billing' => l10n.platformNavBilling,
    '/platform/revenue' => l10n.platformNavRevenue,
    '/platform/plans' => l10n.platformNavPlans,
    '/platform/storage' => l10n.platformNavStorage,
    '/platform/alerts' => l10n.platformNavAlerts,
    '/platform/audit' => l10n.platformNavAudit,
    '/platform/health' => l10n.platformNavHealth,
    '/platform/otp' => 'OTP',
    '/platform/billing-subscriptions' => 'Store Subscriptions',
    '/platform/billing-transactions' => 'Transactions',
    '/platform/billing-gateway' => 'Payment Gateway',
    '/platform/billing-trial' => 'Trial Settings',
    '/platform/billing-analytics' => 'Revenue Analytics',
    _ => path,
  };
}

String localizedPlatformSectionTitle(AppLocalizations l10n, String section) {
  return switch (section) {
    'overview' => l10n.platformNavOverview,
    'business' => l10n.platformNavBusiness,
    'monetization' => 'Billing & Monetization',
    'operations' => l10n.platformNavOperations,
    _ => section,
  };
}
