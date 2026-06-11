import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/session_provider.dart';
import '../features/billing/application/subscription_lock_provider.dart';

/// Notifies [GoRouter] when auth session or subscription lock changes.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
    _ref.listen(subscriptionLockProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
