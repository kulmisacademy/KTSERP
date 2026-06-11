import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/ux/app_transitions.dart';

import '../features/accounting/presentation/accounting_dashboard_page.dart';
import '../features/accounting/presentation/add_journal_entry_page.dart';
import '../features/accounting/presentation/chart_of_accounts_page.dart';
import '../features/accounting/presentation/deposit_withdrawal_page.dart';
import '../features/accounting/presentation/general_ledger_page.dart';
import '../features/accounting/presentation/journal_entries_page.dart';
import '../features/accounting/presentation/payment_accounts_page.dart';
import '../features/accounting/presentation/reports/balance_sheet_page.dart';
import '../features/accounting/presentation/reports/cash_flow_page.dart';
import '../features/accounting/presentation/reports/profit_loss_page.dart';
import '../features/accounting/presentation/reports/trial_balance_page.dart';
import '../features/auth/application/session_provider.dart';
import '../features/auth/presentation/access_denied_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_store_page.dart';
import '../features/auth/presentation/welcome_page.dart';
import '../features/users/domain/app_permission.dart';
import '../features/brands/presentation/brands_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/customers/presentation/customers_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/debts/presentation/customer_debt_profile_page.dart';
import '../features/debts/presentation/debts_page.dart';
import '../features/debts/presentation/public_debt_page.dart';
import '../features/debts/presentation/supplier_debt_profile_page.dart';
import '../features/expenses/presentation/expenses_page.dart';
import '../features/inventory/presentation/inventory_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/pos/presentation/pos_page.dart';
import '../features/products/presentation/product_detail_page.dart';
import '../features/products/presentation/products_page.dart';
import '../features/purchases/presentation/add_purchase_page.dart';
import '../features/purchases/presentation/purchase_detail_page.dart';
import '../features/purchases/presentation/purchase_history_page.dart';
import '../features/ai_insights/presentation/ai_insights_page.dart';
import '../features/reports/presentation/reports_page.dart';
import '../features/custom_sales/presentation/custom_sales_page.dart';
import '../features/custom_sales/presentation/draft_invoices_page.dart';
import '../features/sales/presentation/sale_invoice_page.dart';
import '../features/sales/presentation/sale_receipt_preview_page.dart';
import '../features/sales/presentation/sales_history_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/settings/presentation/qa_validation_page.dart';
import '../features/settings/presentation/system_health_page.dart';
import '../features/platform/presentation/platform_dashboard_page.dart';
import '../features/platform/presentation/platform_audit_page.dart';
import '../features/platform/presentation/platform_billing_page.dart';
import '../features/platform/presentation/platform_health_page.dart';
import '../features/platform/presentation/platform_otp_page.dart';
import '../features/platform/presentation/platform_notifications_page.dart';
import '../features/platform/presentation/platform_revenue_page.dart';
import '../features/platform/presentation/platform_search_page.dart';
import '../features/platform/presentation/platform_storage_page.dart';
import '../features/platform/presentation/platform_plans_page.dart';
import '../features/platform/presentation/platform_shell.dart';
import '../features/platform/presentation/platform_store_detail_page.dart';
import '../features/platform/presentation/platform_stores_page.dart';
import '../features/platform/presentation/platform_monetization_pages.dart';
import '../features/billing/application/subscription_lock_provider.dart';
import '../features/billing/presentation/store_billing_page.dart';
import '../features/billing/presentation/subscription_expired_page.dart';
import '../features/suppliers/presentation/suppliers_page.dart';
import '../features/users/domain/permission_registry.dart';
import '../features/users/presentation/create_user_page.dart';
import '../features/users/presentation/user_permissions_page.dart';
import '../features/users/presentation/user_profile_page.dart';
import '../features/users/presentation/users_management_page.dart';
import '../core/store_context.dart';
import '../sync/sync_queue_page.dart';
import 'router_refresh.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      if (!session.isReady) return null;

      final loc = state.matchedLocation;
      final authRoutes = {
        '/welcome',
        '/login',
        '/register',
        '/forgot-password',
        '/onboarding',
      };
      final isAuthRoute = authRoutes.contains(loc);

      if (loc.startsWith('/debt/')) return null;

      if (loc.startsWith('/platform')) {
        if (!session.isAuthenticated) return '/welcome';
        if (!StoreContext.isSuperAdmin) return _defaultHomeRoute();
        return null;
      }

      if (!session.isAuthenticated && !isAuthRoute) {
        return '/welcome';
      }
      if (session.isAuthenticated && isAuthRoute && loc != '/onboarding') {
        return _defaultHomeRoute();
      }

      if (session.isAuthenticated && !StoreContext.isSuperAdmin) {
        final lock = ref.read(subscriptionLockProvider);
        if (lock.isLocked) {
          if (loc == '/billing' &&
              !StoreContext.can(AppPermission.subscriptionView) &&
              !StoreContext.isStoreOwner) {
            return '/subscription-expired';
          }
          if (loc == '/settings' &&
              !StoreContext.can(AppPermission.settingsView)) {
            return '/subscription-expired';
          }
          final isOwnProfile = loc.startsWith('/users/') &&
              StoreContext.userId != null &&
              loc.contains(StoreContext.userId!);
          const allowedWhenLocked = {'/subscription-expired'};
          if (!allowedWhenLocked.contains(loc) &&
              loc != '/billing' &&
              loc != '/settings' &&
              !isOwnProfile &&
              !loc.startsWith('/debt/')) {
            return '/subscription-expired';
          }
        }
      }

      if (session.isAuthenticated) {
        final required = InventraxPermissionRegistry.permissionForRoute(loc);
        if (required != null && !StoreContext.can(required)) {
          return '/access-denied?route=${Uri.encodeComponent(loc)}';
        }
        if (loc == '/billing' &&
            !StoreContext.can(AppPermission.subscriptionView) &&
            !StoreContext.isStoreOwner) {
          return '/access-denied?route=${Uri.encodeComponent(loc)}';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterStorePage(
          prefillEmail: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/access-denied',
        builder: (context, state) => AccessDeniedPage(
          blockedRoute: state.uri.queryParameters['route'],
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/pos',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const PosPage(),
        ),
      ),
      GoRoute(
        path: '/products',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const ProductsPage(),
        ),
        routes: [
          GoRoute(
            path: ':productId',
            pageBuilder: (context, state) => InventraTransitions.slideUp(
              key: state.pageKey,
              child: ProductDetailPage(
                productId: state.pathParameters['productId']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/brands',
        builder: (context, state) => const BrandsPage(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
      ),
      GoRoute(
        path: '/purchases',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const PurchaseHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/purchases/add',
        builder: (context, state) => const AddPurchasePage(),
      ),
      GoRoute(
        path: '/purchases/:id',
        builder: (context, state) => PurchaseDetailPage(
          purchaseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/sales/custom',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const CustomSalesPage(),
        ),
      ),
      GoRoute(
        path: '/sales/drafts',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const DraftInvoicesPage(),
        ),
      ),
      GoRoute(
        path: '/sales',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const SalesHistoryPage(),
        ),
        routes: [
          GoRoute(
            path: ':id/receipt',
            builder: (context, state) => SaleReceiptPreviewPage(
              saleId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: ':id/invoice',
            builder: (context, state) => SaleInvoicePage(
              saleId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/customers',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const CustomersPage(),
        ),
      ),
      GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SuppliersPage(),
      ),
      GoRoute(
        path: '/debts',
        builder: (context, state) => const DebtsPage(),
      ),
      GoRoute(
        path: '/debts/customer/:id',
        builder: (context, state) => CustomerDebtProfilePage(
          customerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/debts/supplier/:id',
        builder: (context, state) => SupplierDebtProfilePage(
          supplierId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/debt/:token',
        builder: (context, state) => PublicDebtPage(
          token: state.pathParameters['token']!,
        ),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpensesPage(),
      ),
      GoRoute(
        path: '/accounting',
        builder: (context, state) => const AccountingDashboardPage(),
      ),
      GoRoute(
        path: '/accounting/chart',
        builder: (context, state) => const ChartOfAccountsPage(),
      ),
      GoRoute(
        path: '/accounting/journals',
        builder: (context, state) => const JournalEntriesPage(),
      ),
      GoRoute(
        path: '/accounting/journals/new',
        builder: (context, state) => const AddJournalEntryPage(),
      ),
      GoRoute(
        path: '/accounting/ledger',
        builder: (context, state) => const GeneralLedgerPage(),
      ),
      GoRoute(
        path: '/accounting/cash',
        builder: (context, state) => const DepositWithdrawalPage(),
      ),
      GoRoute(
        path: '/accounting/payment-accounts',
        builder: (context, state) => const PaymentAccountsPage(),
      ),
      GoRoute(
        path: '/accounting/reports/trial-balance',
        builder: (context, state) => const TrialBalancePage(),
      ),
      GoRoute(
        path: '/accounting/reports/profit-loss',
        builder: (context, state) => const ProfitLossPage(),
      ),
      GoRoute(
        path: '/accounting/reports/balance-sheet',
        builder: (context, state) => const BalanceSheetPage(),
      ),
      GoRoute(
        path: '/accounting/reports/cash-flow',
        builder: (context, state) => const CashFlowPage(),
      ),
      GoRoute(
        path: '/reports',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const ReportsPage(),
        ),
      ),
      GoRoute(
        path: '/ai-insights',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const AiInsightsPage(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/billing',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const StoreBillingPage(),
        ),
      ),
      GoRoute(
        path: '/subscription-expired',
        pageBuilder: (context, state) => InventraTransitions.fade(
          key: state.pageKey,
          child: const SubscriptionExpiredPage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'health',
            builder: (context, state) => const SystemHealthPage(),
          ),
          GoRoute(
            path: 'qa',
            builder: (context, state) => const QaValidationPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersManagementPage(),
      ),
      GoRoute(
        path: '/users/create',
        builder: (context, state) => const CreateUserPage(),
      ),
      GoRoute(
        path: '/users/:id/permissions',
        builder: (context, state) => UserPermissionsPage(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) => UserProfilePage(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncQueuePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => PlatformShell(child: child),
        routes: [
          GoRoute(
            path: '/platform',
            redirect: (context, state) => '/platform/dashboard',
          ),
          GoRoute(
            path: '/platform/dashboard',
            builder: (context, state) => const PlatformDashboardPage(),
          ),
          GoRoute(
            path: '/platform/stores',
            builder: (context, state) => const PlatformStoresPage(),
            routes: [
              GoRoute(
                path: ':storeId',
                builder: (context, state) => PlatformStoreDetailPage(
                  storeId: state.pathParameters['storeId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/platform/plans',
            builder: (context, state) => const PlatformPlansPage(),
          ),
          GoRoute(
            path: '/platform/billing',
            builder: (context, state) => const PlatformBillingPage(),
          ),
          GoRoute(
            path: '/platform/revenue',
            builder: (context, state) => const PlatformRevenuePage(),
          ),
          GoRoute(
            path: '/platform/storage',
            builder: (context, state) => const PlatformStoragePage(),
          ),
          GoRoute(
            path: '/platform/audit',
            builder: (context, state) => const PlatformAuditPage(),
          ),
          GoRoute(
            path: '/platform/health',
            builder: (context, state) => const PlatformHealthPage(),
          ),
          GoRoute(
            path: '/platform/otp',
            builder: (context, state) => const PlatformOtpPage(),
          ),
          GoRoute(
            path: '/platform/search',
            builder: (context, state) => const PlatformSearchPage(),
          ),
          GoRoute(
            path: '/platform/alerts',
            builder: (context, state) => const PlatformNotificationsPage(),
          ),
          GoRoute(
            path: '/platform/billing-subscriptions',
            builder: (context, state) => const PlatformStoreSubscriptionsPage(),
          ),
          GoRoute(
            path: '/platform/billing-transactions',
            builder: (context, state) => const PlatformTransactionsPage(),
          ),
          GoRoute(
            path: '/platform/billing-gateway',
            builder: (context, state) => const PlatformPaymentGatewayPage(),
          ),
          GoRoute(
            path: '/platform/billing-trial',
            builder: (context, state) => const PlatformTrialSettingsPage(),
          ),
          GoRoute(
            path: '/platform/billing-analytics',
            builder: (context, state) => const PlatformBillingAnalyticsPage(),
          ),
        ],
      ),
    ],
  );
});

String _defaultHomeRoute() {
  if (StoreContext.isSuperAdmin) return '/platform/dashboard';
  for (final nav in InventraxPermissionRegistry.sidebarNav) {
    if (StoreContext.can(nav.permissionId)) return nav.route;
  }
  return '/dashboard';
}
