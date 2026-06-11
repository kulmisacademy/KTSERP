import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../billing/application/billing_providers.dart';
import '../../../observability/system_health_providers.dart';

class PlatformHealthOverview {
  const PlatformHealthOverview({
    required this.failedPayments24h,
    required this.failedPayments30d,
    required this.realtimeState,
    required this.pendingSync,
    required this.failedSync,
  });

  final int failedPayments24h;
  final int failedPayments30d;
  final String realtimeState;
  final int pendingSync;
  final int failedSync;
}

final platformHealthOverviewProvider =
    FutureProvider.autoDispose<PlatformHealthOverview?>((ref) async {
  ref.watch(systemHealthSnapshotProvider);
  final since = DateTime.now().subtract(const Duration(hours: 24));
  final failed24h =
      await ref.watch(billingRepositoryProvider).countFailedPaymentsSince(since);
  final analytics = await ref.watch(platformBillingAnalyticsProvider.future);
  final health = await ref.watch(systemHealthSnapshotProvider.future);

  return PlatformHealthOverview(
    failedPayments24h: failed24h,
    failedPayments30d: analytics?.failedPayments30d ?? 0,
    realtimeState: health.realtimeState.name,
    pendingSync: health.pendingQueue,
    failedSync: health.failedQueue,
  );
});
