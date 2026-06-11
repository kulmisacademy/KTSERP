import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/billing_models.dart';
import 'billing_providers.dart';

class SubscriptionAccess {
  const SubscriptionAccess({
    required this.allowed,
    this.reason,
    this.snapshot,
  });

  final bool allowed;
  final String? reason;
  final StoreBillingSnapshot? snapshot;

  static const granted = SubscriptionAccess(allowed: true);
}

/// Central subscription middleware — checks status + feature flags.
class SubscriptionGuard {
  const SubscriptionGuard();

  SubscriptionAccess evaluateSnapshot(StoreBillingSnapshot snap) {
    final sub = snap.subscription;
    final graceDays = snap.billingSettings.gracePeriodDays;

    if (sub.isTrialing && (sub.daysRemaining ?? 0) <= 0) {
      return SubscriptionAccess(
        allowed: false,
        reason: 'Your free trial has ended. Choose a plan to continue.',
        snapshot: snap,
      );
    }

    if (sub.isExpired) {
      if (_withinGrace(sub, graceDays)) {
        return SubscriptionAccess(allowed: true, snapshot: snap);
      }
      return SubscriptionAccess(
        allowed: false,
        reason:
            'Your subscription has expired. Renew to continue using KULMIS ERP.',
        snapshot: snap,
      );
    }

    if (sub.currentPeriodEnd != null &&
        DateTime.now().isAfter(sub.currentPeriodEnd!) &&
        !_withinGrace(sub, graceDays)) {
      return SubscriptionAccess(
        allowed: false,
        reason:
            'Your subscription period has ended. Renew to restore full access.',
        snapshot: snap,
      );
    }

    return SubscriptionAccess(allowed: true, snapshot: snap);
  }

  int? daysUntilHardLock(StoreBillingSnapshot snap) {
    final sub = snap.subscription;
    final graceDays = snap.billingSettings.gracePeriodDays;
    final end = sub.currentPeriodEnd ?? sub.trialEndsAt;
    if (end == null) return null;
    final hardLockAt = end.add(Duration(days: graceDays));
    final remaining = hardLockAt.difference(DateTime.now()).inDays;
    if (remaining < 0) return 0;
    if (!sub.isExpired &&
        !DateTime.now().isAfter(end) &&
        (sub.daysRemaining ?? 99) > 7) {
      return null;
    }
    return remaining;
  }

  bool _withinGrace(StoreSubscriptionInfo sub, int graceDays) {
    final end = sub.currentPeriodEnd ?? sub.trialEndsAt;
    if (end == null) return false;
    return DateTime.now().isBefore(end.add(Duration(days: graceDays)));
  }

  Future<SubscriptionAccess> checkAccess(WidgetRef ref) async {
    final snap = await ref.read(storeBillingProvider.future);
    if (snap == null) return SubscriptionAccess.granted;
    return evaluateSnapshot(snap);
  }

  Future<bool> hasFeature(WidgetRef ref, String feature) async {
    final snap = await ref.read(storeBillingProvider.future);
    if (snap == null) return true;
    final sub = snap.subscription;
    if (sub.isExpired) return false;
    return sub.hasFeature(feature);
  }

  bool shouldShowTrialBanner(StoreBillingSnapshot? snap) {
    if (snap == null) return false;
    final sub = snap.subscription;
    if (!sub.isTrialing) return false;
    final days = sub.daysRemaining ?? 0;
    return days <= 7;
  }
}

final subscriptionGuardProvider = Provider<SubscriptionGuard>(
  (ref) => const SubscriptionGuard(),
);
