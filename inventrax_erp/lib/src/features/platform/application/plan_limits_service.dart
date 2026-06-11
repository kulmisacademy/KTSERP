import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../data/local/app_database.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../../billing/domain/billing_models.dart';
import '../domain/platform_models.dart';

final planLimitsServiceProvider = Provider<PlanLimitsService>(
  (ref) => const PlanLimitsService(),
);

/// Enforces subscription plan limits (products, users, storage, features).
class PlanLimitsService {
  const PlanLimitsService();

  Future<SubscriptionAccessResult> checkSubscriptionAccess() async {
    final client = supabaseClient;
    if (client == null) return SubscriptionAccessResult.ok;

    try {
      final raw = await client.rpc('inventrax_store_billing_snapshot');
      if (raw is! Map<String, dynamic>) return SubscriptionAccessResult.ok;
      final snap = StoreBillingSnapshot.fromJson(raw);
      final sub = snap.subscription;

      if (sub.isExpired) {
        return SubscriptionAccessResult(
          allowed: false,
          message:
              'Subscription expired. Renew your plan to continue using premium features.',
        );
      }

      if (sub.isTrialing && (sub.daysRemaining ?? 0) <= 0) {
        return SubscriptionAccessResult(
          allowed: false,
          message: 'Free trial ended. Choose a plan to continue.',
        );
      }

      return SubscriptionAccessResult.ok;
    } catch (_) {
      return SubscriptionAccessResult.ok;
    }
  }

  Future<bool> hasFeature(String feature) async {
    final plan = await _currentPlan();
    if (plan == null) return true;
    if (plan.features.contains('*')) return true;
    return plan.features.contains(feature);
  }

  Future<PlanLimitResult> checkCanAddProduct(AppDatabase db) async {
    final access = await checkSubscriptionAccess();
    if (!access.allowed) {
      return PlanLimitResult(allowed: false, message: access.message);
    }
    final count = await db.countProducts(
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
    );
    final limit = await _productLimit();
    if (limit == null) return const PlanLimitResult(allowed: true);
    if (count < limit) return const PlanLimitResult(allowed: true);
    return PlanLimitResult(
      allowed: false,
      message: 'Upgrade your plan to add more products. '
          'Limit: $limit (current: $count).',
    );
  }

  Future<PlanLimitResult> checkCanAddUser(int currentUserCount) async {
    final access = await checkSubscriptionAccess();
    if (!access.allowed) {
      return PlanLimitResult(allowed: false, message: access.message);
    }
    final limit = await _userLimit();
    if (limit == null) return const PlanLimitResult(allowed: true);
    if (currentUserCount < limit) return const PlanLimitResult(allowed: true);
    return PlanLimitResult(
      allowed: false,
      message: 'Upgrade your plan to add more users. Limit: $limit.',
    );
  }

  Future<int?> _productLimit() async {
    final plan = await _currentPlan();
    return plan?.productLimit;
  }

  Future<int?> _userLimit() async {
    final plan = await _currentPlan();
    return plan?.userLimit;
  }

  Future<SubscriptionPlan?> _currentPlan() async {
    final client = supabaseClient;
    if (client == null) return null;
    try {
      final sub = await client
          .from('subscriptions')
          .select('plan_id, status, subscription_plans(*)')
          .eq('tenant_id', StoreContext.tenantId)
          .maybeSingle();
      if (sub == null) return null;
      final status = sub['status'] as String? ?? '';
      if (status == 'expired' || status == 'suspended') {
        return null;
      }
      final planRaw = sub['subscription_plans'];
      if (planRaw is Map) {
        return SubscriptionPlan.fromJson(Map<String, dynamic>.from(planRaw));
      }
      final planId = sub['plan_id'] as String?;
      if (planId == null) return null;
      final row = await client
          .from('subscription_plans')
          .select()
          .eq('id', planId)
          .maybeSingle();
      if (row == null) return null;
      return SubscriptionPlan.fromJson(Map<String, dynamic>.from(row));
    } catch (_) {
      return null;
    }
  }
}
