import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/platform_repository.dart';
import '../domain/platform_models.dart';

final platformRepositoryProvider = Provider<PlatformRepository>(
  (ref) => const PlatformRepository(),
);

final platformDashboardProvider =
    FutureProvider.autoDispose<PlatformDashboardMetrics?>((ref) async {
  return ref.watch(platformRepositoryProvider).fetchDashboard();
});

final platformStoresProvider =
    FutureProvider.autoDispose.family<List<PlatformStoreRow>, String?>(
  (ref, search) async {
    return ref.watch(platformRepositoryProvider).listStores(search: search);
  },
);

final platformStoreDetailProvider =
    FutureProvider.autoDispose.family<PlatformStoreDetail?, String>(
  (ref, storeId) async {
    return ref.watch(platformRepositoryProvider).fetchStoreDetail(storeId);
  },
);

final subscriptionPlansProvider =
    FutureProvider.autoDispose<List<SubscriptionPlan>>((ref) async {
  return ref.watch(platformRepositoryProvider).listPlans();
});

final platformAnalyticsProvider =
    FutureProvider.autoDispose<PlatformAnalytics?>((ref) async {
  return ref.watch(platformRepositoryProvider).fetchAnalytics();
});

final platformAuditLogsProvider =
    FutureProvider.autoDispose<List<AdminActivityLogEntry>>((ref) async {
  return ref.watch(platformRepositoryProvider).fetchAuditLogs();
});

final platformSearchProvider =
    FutureProvider.autoDispose.family<PlatformSearchResults?, String>(
  (ref, query) async {
    if (query.trim().length < 2) return null;
    return ref.watch(platformRepositoryProvider).search(query.trim());
  },
);
