import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/session_provider.dart';
import '../store_context.dart';

/// Rebuilds when auth session changes so store settings stream uses the active store.
final activeStoreScopeProvider = Provider<({String tenantId, String storeId})>((ref) {
  ref.watch(sessionProvider);
  if (!StoreContext.isLoggedIn) {
    return (tenantId: StoreContext.defaultTenantId, storeId: StoreContext.defaultStoreId);
  }
  return (tenantId: StoreContext.tenantId, storeId: StoreContext.storeId);
});
