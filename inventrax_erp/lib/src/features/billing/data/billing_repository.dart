import '../../../sync/supabase_bootstrap.dart';
import '../../platform/domain/platform_models.dart';
import '../domain/billing_models.dart';

class BillingRepository {
  const BillingRepository();

  Future<StoreBillingSnapshot?> fetchStoreBilling() async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc('inventrax_store_billing_snapshot');
    if (raw is! Map<String, dynamic>) return null;
    return StoreBillingSnapshot.fromJson(raw);
  }

  Future<List<SubscriptionPlan>> listActivePlans() async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('subscription_plans')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (rows as List)
        .map((e) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<PaymentTransaction>> listStoreTransactions({int limit = 50}) async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('payment_transactions')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => PaymentTransaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<PaymentTransaction>> listAllTransactions({int limit = 100}) async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('payment_transactions')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => PaymentTransaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<BillingAnalytics?> fetchPlatformAnalytics() async {
    final client = supabaseClient;
    if (client == null) return null;
    final raw = await client.rpc('inventrax_platform_billing_analytics');
    if (raw is! Map<String, dynamic>) return null;
    return BillingAnalytics.fromJson(raw);
  }

  Future<int> countFailedPaymentsSince(DateTime since) async {
    final client = supabaseClient;
    if (client == null) return 0;
    final rows = await client
        .from('payment_transactions')
        .select('id')
        .eq('status', 'failed')
        .gte('created_at', since.toUtc().toIso8601String());
    return (rows as List).length;
  }

  Future<Map<String, dynamic>?> fetchBillingSettings() async {
    final client = supabaseClient;
    if (client == null) return null;
    final row = await client
        .from('billing_settings')
        .select()
        .eq('id', 'global')
        .maybeSingle();
    if (row == null) return null;
    return Map<String, dynamic>.from(row);
  }

  Future<void> updateBillingSettings(Map<String, dynamic> patch) async {
    final client = supabaseClient;
    if (client == null) return;
    await client.from('billing_settings').upsert({
      'id': 'global',
      ...patch,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<PaymentStatusSnapshot?> fetchPaymentStatus(String transactionId) async {
    final client = supabaseClient;
    if (client == null) return null;
    try {
      final raw = await client.rpc(
        'inventrax_billing_payment_status',
        params: {'p_transaction_id': transactionId},
      );
      if (raw is Map) {
        return PaymentStatusSnapshot.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> cancelPayment(String transactionId) async {
    final client = supabaseClient;
    if (client == null) return false;
    try {
      final raw = await client.rpc(
        'inventrax_billing_cancel_payment',
        params: {'p_transaction_id': transactionId},
      );
      if (raw is Map) {
        return raw['cancelled'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<Map<String, dynamic>>> listStoreSubscriptions() async {
    final client = supabaseClient;
    if (client == null) return [];
    final rows = await client
        .from('subscriptions')
        .select('*, subscription_plans(name, monthly_price_cents), stores(name)')
        .order('updated_at', ascending: false);
    return (rows as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
