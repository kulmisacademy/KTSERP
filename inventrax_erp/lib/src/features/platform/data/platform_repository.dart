import '../../../sync/supabase_bootstrap.dart';
import '../domain/platform_models.dart';

class PlatformRepository {
  const PlatformRepository();

  Future<PlatformDashboardMetrics?> fetchDashboard() async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc('inventrax_platform_dashboard');
    if (raw is! Map<String, dynamic>) return null;
    return PlatformDashboardMetrics.fromJson(raw);
  }

  Future<List<PlatformStoreRow>> listStores({String? search}) async {
    final client = supabaseClient;
    if (client == null) return [];
    final raw = await client.rpc(
      'inventrax_platform_list_stores',
      params: {'p_search': search},
    );
    if (raw is! List) return [];
    return raw
        .map((e) => PlatformStoreRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<PlatformStoreDetail?> fetchStoreDetail(String storeId) async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc(
      'inventrax_platform_store_detail',
      params: {'p_store_id': storeId},
    );
    if (raw is! Map<String, dynamic>) return null;
    return PlatformStoreDetail.fromJson(raw);
  }

  Future<List<SubscriptionPlan>> listPlans() async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('subscription_plans')
        .select()
        .order('sort_order');
    return (rows as List)
        .map((e) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> upsertPlan(SubscriptionPlan plan) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.from('subscription_plans').upsert(plan.toUpsertJson());
  }

  Future<void> deletePlan(String planId) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.from('subscription_plans').delete().eq('id', planId);
  }

  Future<void> updateSubscription({
    required String tenantId,
    required String planId,
    required String status,
    int? trialDays,
  }) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.rpc(
      'inventrax_platform_update_subscription',
      params: {
        'p_tenant_id': tenantId,
        'p_plan_id': planId,
        'p_status': status,
        'p_trial_days': trialDays,
      },
    );
  }

  Future<void> setStoreStatus(String storeId, String status) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.rpc(
      'inventrax_platform_set_store_status',
      params: {'p_store_id': storeId, 'p_status': status},
    );
  }

  Future<void> refreshUsage({String? storeId}) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.rpc(
      'inventrax_refresh_store_usage',
      params: {'p_store_id': storeId},
    );
  }

  Future<Map<String, dynamic>> impersonateStore(String storeId) async {
    final client = supabaseClient;
    if (client == null) return {};
    final raw = await client.rpc(
      'inventrax_platform_impersonate_store',
      params: {'p_store_id': storeId},
    );
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  Future<void> endImpersonation() async {
    final client = supabaseClient;
    if (client == null) return;
    await client.rpc('inventrax_platform_end_impersonation');
  }

  Future<PlatformAnalytics?> fetchAnalytics() async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc('inventrax_platform_analytics');
    if (raw is! Map<String, dynamic>) return null;
    return PlatformAnalytics.fromJson(raw);
  }

  Future<PlatformSearchResults?> search(String query) async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc(
      'inventrax_platform_search',
      params: {'p_query': query},
    );
    if (raw is! Map<String, dynamic>) return null;
    return PlatformSearchResults.fromJson(raw);
  }

  Future<List<AdminActivityLogEntry>> fetchAuditLogs({int limit = 80}) async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('admin_activity_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => AdminActivityLogEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> refreshAllMetrics() async {
    final client = supabaseClient;
    if (client == null) return;
    await client.rpc('inventrax_refresh_store_usage');
    await client.rpc('inventrax_refresh_storage_usage');
  }

  Future<Map<String, dynamic>?> fetchTenantSubscription(String tenantId) async {
    final client = supabaseClient;
    if (client == null) return null;
    final rows = await client
        .from('subscriptions')
        .select('*, subscription_plans(*)')
        .eq('tenant_id', tenantId)
        .maybeSingle();
    if (rows == null) return null;
    return Map<String, dynamic>.from(rows);
  }
}
