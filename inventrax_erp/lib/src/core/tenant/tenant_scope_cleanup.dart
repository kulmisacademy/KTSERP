import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../features/ai_insights/application/ai_insights_providers.dart';
import '../../features/ai_insights/data/ai_insights_cache.dart';
import '../../features/billing/application/billing_providers.dart';
import '../../features/billing/application/subscription_lock_provider.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../features/pos/presentation/pos_controller.dart';
import '../../features/products/presentation/product_catalog_provider.dart';
import '../../sync/realtime_service.dart';
import '../../sync/sync_service.dart';
import '../store_context.dart';

/// Clears local tenant cache and invalidates store-scoped providers on logout / store switch.
abstract final class TenantScopeCleanup {
  static Future<void> cleanupForeignTenantData(AppDatabase db) async {
    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    if (tenantId.isEmpty || storeId.isEmpty) return;
    await db.cleanupForeignTenantData(tenantId: tenantId, storeId: storeId);
    await AiInsightsCache().clearExceptStore(storeId);
  }

  static Future<void> purgeLocalStoreData(AppDatabase db) async {
    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    if (storeId.isEmpty || storeId == StoreContext.defaultStoreId) return;
    await db.purgeLocalDataForScope(tenantId: tenantId, storeId: storeId);
    await AiInsightsCache().clearExceptStore('');
  }

  static void invalidateStoreScopedProviders(Ref ref) {
    ref.invalidate(dashboardMetricsProvider);
    ref.invalidate(dashboardKpisProvider);
    ref.invalidate(salesTrendProvider);
    ref.invalidate(lowStockProvider);
    ref.invalidate(recentSalesProvider);
    ref.invalidate(dashboardDebtAlertsProvider);
    ref.invalidate(productCatalogProvider);
    ref.invalidate(productInventoryStatsProvider);
    ref.invalidate(productQueryProvider);
    ref.invalidate(productCatalogFilterProvider);
    ref.invalidate(heldSalesProvider);
    ref.invalidate(posControllerProvider);
    ref.invalidate(aiBusinessSnapshotProvider);
    ref.invalidate(aiInsightsCacheProvider);
    ref.invalidate(syncWorkerProvider);
    ref.invalidate(realtimeServiceProvider);
    ref.invalidate(storeBillingProvider);
    ref.invalidate(subscriptionLockProvider);
  }
}
