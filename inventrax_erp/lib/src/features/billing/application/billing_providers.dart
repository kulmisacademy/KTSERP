import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/domain/platform_models.dart';
import '../data/billing_repository.dart';
import '../data/payment_service.dart';
import '../domain/billing_models.dart';

final billingRepositoryProvider = Provider<BillingRepository>(
  (ref) => const BillingRepository(),
);

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => const PaymentService(),
);

final storeBillingProvider = FutureProvider<StoreBillingSnapshot?>((ref) async {
  return ref.watch(billingRepositoryProvider).fetchStoreBilling();
});

final activePlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  return ref.watch(billingRepositoryProvider).listActivePlans();
});

final storeTransactionsProvider =
    FutureProvider<List<PaymentTransaction>>((ref) async {
  return ref.watch(billingRepositoryProvider).listStoreTransactions();
});

final platformBillingAnalyticsProvider =
    FutureProvider<BillingAnalytics?>((ref) async {
  return ref.watch(billingRepositoryProvider).fetchPlatformAnalytics();
});

final platformTransactionsProvider =
    FutureProvider<List<PaymentTransaction>>((ref) async {
  return ref.watch(billingRepositoryProvider).listAllTransactions();
});

final platformStoreSubscriptionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(billingRepositoryProvider).listStoreSubscriptions();
});

final billingSettingsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(billingRepositoryProvider).fetchBillingSettings();
});
