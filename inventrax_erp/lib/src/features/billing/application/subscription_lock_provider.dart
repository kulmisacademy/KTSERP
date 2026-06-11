import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session_provider.dart';
import 'billing_providers.dart';
import 'subscription_guard.dart';

class SubscriptionLockState {
  const SubscriptionLockState({
    this.isLocked = false,
    this.message,
    this.isLoading = true,
    this.daysUntilLock,
  });

  final bool isLocked;
  final String? message;
  final bool isLoading;
  final int? daysUntilLock;

  static const unlocked = SubscriptionLockState(isLoading: false);
}

/// Synchronous subscription lock state for router + sync middleware.
class SubscriptionLock extends Notifier<SubscriptionLockState> {
  @override
  SubscriptionLockState build() {
    if (!ref.watch(sessionProvider.select((s) => s.isAuthenticated))) {
      return SubscriptionLockState.unlocked;
    }

    ref.listen(storeBillingProvider, (_, next) {
      state = _evaluate(next);
    });

    return _evaluate(ref.watch(storeBillingProvider));
  }

  SubscriptionLockState _evaluate(AsyncValue<dynamic> billing) {
    return billing.when(
      loading: () => const SubscriptionLockState(isLoading: true),
      error: (_, __) => SubscriptionLockState.unlocked,
      data: (snap) {
        if (snap == null) return SubscriptionLockState.unlocked;
        final guard = const SubscriptionGuard();
        final access = guard.evaluateSnapshot(snap);
        if (!access.allowed) {
          return SubscriptionLockState(
            isLocked: true,
            message: access.reason,
            isLoading: false,
          );
        }
        final days = guard.daysUntilHardLock(snap);
        return SubscriptionLockState(
          isLoading: false,
          daysUntilLock: days,
        );
      },
    );
  }
}

final subscriptionLockProvider =
    NotifierProvider<SubscriptionLock, SubscriptionLockState>(
  SubscriptionLock.new,
);
