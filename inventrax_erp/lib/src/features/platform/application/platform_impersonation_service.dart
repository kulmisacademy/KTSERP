import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../auth/application/session_provider.dart';
import '../../auth/domain/app_role.dart';
import '../../users/domain/permission_registry.dart';
import '../../../sync/sync_service.dart';
import 'platform_providers.dart';

class ImpersonationState {
  const ImpersonationState({
    this.active = false,
    this.storeId,
    this.storeName,
    this.tenantId,
  });

  final bool active;
  final String? storeId;
  final String? storeName;
  final String? tenantId;
}

final platformImpersonationProvider =
    NotifierProvider<PlatformImpersonationController, ImpersonationState>(
  PlatformImpersonationController.new,
);

class PlatformImpersonationController extends Notifier<ImpersonationState> {
  String? _savedTenantId;
  String? _savedStoreId;
  String? _savedStoreName;

  @override
  ImpersonationState build() => const ImpersonationState();

  Future<void> impersonateStore({
    required String storeId,
    required String tenantId,
    required String storeName,
  }) async {
    if (!StoreContext.isSuperAdmin) return;

    _savedTenantId = StoreContext.tenantId;
    _savedStoreId = StoreContext.storeId;
    _savedStoreName = StoreContext.storeName;

    await ref.read(platformRepositoryProvider).impersonateStore(storeId);

    final auth = ref.read(authRepositoryProvider);
    await auth.applyStoreContext(
      tenantId: tenantId,
      storeId: storeId,
      storeName: storeName,
      role: AppRole.superAdmin,
      permissions: InventraxPermissionRegistry.templateForRole(AppRole.superAdmin),
    );

    ref.read(sessionProvider.notifier).refreshStoreName(storeName);

    state = ImpersonationState(
      active: true,
      storeId: storeId,
      storeName: storeName,
      tenantId: tenantId,
    );

    await ref.read(syncWorkerProvider.notifier).fullSync(forceFullPull: true);
  }

  Future<void> endImpersonation() async {
    if (!state.active) return;

    await ref.read(platformRepositoryProvider).endImpersonation();

    final auth = ref.read(authRepositoryProvider);
    if (_savedTenantId != null && _savedStoreId != null) {
      await auth.applyStoreContext(
        tenantId: _savedTenantId!,
        storeId: _savedStoreId!,
        storeName: _savedStoreName ?? 'Platform',
        role: AppRole.superAdmin,
        permissions: InventraxPermissionRegistry.templateForRole(AppRole.superAdmin),
      );
      ref.read(sessionProvider.notifier).refreshStoreName(_savedStoreName);
    }

    _savedTenantId = null;
    _savedStoreId = null;
    _savedStoreName = null;
    state = const ImpersonationState();

    await ref.read(syncWorkerProvider.notifier).fullSync(forceFullPull: true);
  }
}
