import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/store_context.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/db_provider.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../../auth/domain/app_role.dart';
import '../domain/permission_catalog.dart';
import '../domain/permission_registry.dart';
import '../domain/permission_service.dart';
import '../domain/store_user.dart';
import 'activity_logger.dart';

const _uuid = Uuid();

class UsersRepository {
  UsersRepository(this._db, this._activity);

  final AppDatabase _db;
  final ActivityLogger _activity;

  Future<List<StoreUser>> listStoreUsers() async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient;
      if (client != null) {
        try {
          final rows = await client
              .from('profiles')
              .select(
                'id, tenant_id, store_id, email, full_name, phone, role_id, '
                'is_active, status, avatar_url, last_login_at',
              )
              .eq('store_id', StoreContext.storeId)
              .eq('tenant_id', StoreContext.tenantId)
              .order('created_at');

          final users = <StoreUser>[];
          for (final row in rows as List) {
            final id = row['id'] as String;
            final overrides = await _fetchUserOverrides(client, id);
            users.add(_mapProfile(row as Map<String, dynamic>, overrides));
          }
          return users;
        } catch (e) {
          if (kDebugMode) debugPrint('listStoreUsers: $e');
        }
      }
    }
    final rows = await _db.listStoreStaffRows(storeId: StoreContext.storeId);
    return rows.map(_mapStaffRow).toList();
  }

  Future<StoreUser?> getUser(String id) async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient;
      if (client != null) {
        try {
          final row = await client
              .from('profiles')
              .select(
                'id, tenant_id, store_id, email, full_name, phone, role_id, '
                'is_active, status, avatar_url, last_login_at',
              )
              .eq('id', id)
              .maybeSingle();
          if (row != null) {
            final overrides = await getUserPermissionOverrides(id);
            return _mapProfile(row, overrides);
          }
        } catch (e) {
          if (kDebugMode) debugPrint('getUser: $e');
        }
      }
    }
    final row = await _db.getStoreStaffRow(id: id);
    if (row == null) return null;
    final overrides = await getUserPermissionOverrides(id);
    return _mapStaffRow(row, overrides);
  }

  Future<Set<String>> resolveEffectivePermissions(StoreUser user) async {
    final staff = await _db.getStoreStaffRow(id: user.id);
    if (staff?.customPermissionsJson?.startsWith('full:') == true) {
      final raw = staff!.customPermissionsJson!.substring(5);
      return InventraxPermissionRegistry.normalizeGrants(
        raw.split(',').where((s) => s.isNotEmpty),
      );
    }

    final overrides = user.customPermissions.isNotEmpty
        ? user.customPermissions
        : await getUserPermissionOverrides(user.id);

    var grants = InventraxPermissionRegistry.templateForRole(user.role);
    for (final e in overrides.entries) {
      if (e.value) {
        grants.add(e.key);
      } else {
        grants.remove(e.key);
      }
    }
    return InventraxPermissionRegistry.normalizeGrants(grants);
  }

  Future<void> savePermissionSelection({
    required String userId,
    required AppRole role,
    required Set<String> selected,
  }) async {
    final normalized = InventraxPermissionRegistry.normalizeGrants(selected);
    final roleDefaults = InventraxPermissionRegistry.templateForRole(role);
    final overrides = <String, bool>{};
    for (final id in InventraxPermissionRegistry.allPermissionIds()) {
      final wants = normalized.contains(id) ||
          PermissionService(normalized).has(id);
      final roleHas = roleDefaults.contains(id) ||
          PermissionService(roleDefaults).has(id);
      if (wants != roleHas) overrides[id] = wants;
    }
    await setUserPermissions(userId, overrides);
    await _db.setStoreStaffFullPermissions(userId, normalized);
  }

  StoreUser _mapStaffRow(
    dynamic row, [
    Map<String, bool> overrides = const {},
  ]) {
    return StoreUser(
      id: row.id as String,
      tenantId: row.tenantId as String,
      storeId: row.storeId as String,
      email: row.email as String,
      fullName: row.fullName as String,
      phone: row.phone as String?,
      avatarUrl: row.avatarUrl as String?,
      role: AppRole.fromId(row.roleId as String?),
      isActive: row.isActive as bool,
      status: row.status as String,
      lastLoginAt: row.lastLoginAt as DateTime?,
      customPermissions: overrides,
    );
  }

  Future<Set<String>> loadEffectivePermissions({
    required String userId,
    required AppRole role,
  }) async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient;
      if (client != null) {
        try {
          final res = await client.rpc(
            'inventrax_effective_permissions',
            params: {'p_user_id': userId},
          );
          final list = PermissionService.parseList(res as List?);
          if (list.isNotEmpty) return list;
        } catch (e) {
          if (kDebugMode) debugPrint('loadEffectivePermissions: $e');
        }
      }
    }

    final staff = await _db.getStoreStaffRow(id: userId);
    if (staff?.customPermissionsJson?.startsWith('full:') == true) {
      return InventraxPermissionRegistry.normalizeGrants(
        staff!.customPermissionsJson!.substring(5).split(','),
      );
    }
    var grants = InventraxPermissionRegistry.templateForRole(role);
    if (staff?.customPermissionsJson != null) {
      grants = _applyOverrides(grants, staff!.customPermissionsJson!);
    }
    return grants;
  }

  Future<StoreUser> createUser({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    required AppRole role,
    String status = 'active',
    Set<String>? permissionGrants,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient!;
      final res = await client.functions.invoke(
        'create-store-user',
        body: {
          'email': trimmedEmail,
          'password': password,
          'full_name': fullName.trim(),
          'phone': phone?.trim(),
          'role_id': role.id,
        },
      );
      if (res.status != 200) {
        final err = res.data is Map ? res.data['error'] : res.data;
        throw Exception(err?.toString() ?? 'Failed to create user');
      }
      final data = res.data as Map<String, dynamic>;
      final userId = data['user_id'] as String;
      await savePermissionSelection(
        userId: userId,
        role: role,
        selected: permissionGrants ?? InventraxPermissionRegistry.templateForRole(role),
      );
      await _activity.log(
        action: 'user.created',
        entity: 'user',
        entityId: userId,
        newValue: trimmedEmail,
      );
      final users = await listStoreUsers();
      return users.firstWhere((u) => u.id == userId);
    }

    final id = _uuid.v4();
    await _db.upsertStoreStaff(
      id: id,
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      email: trimmedEmail,
      fullName: fullName.trim(),
      phone: phone?.trim(),
      roleId: role.id,
      password: password,
      isActive: status == 'active',
    );
    await savePermissionSelection(
      userId: id,
      role: role,
      selected: permissionGrants ?? InventraxPermissionRegistry.templateForRole(role),
    );
    await _activity.log(
      action: 'user.created',
      entity: 'user',
      entityId: id,
      newValue: trimmedEmail,
    );
    return StoreUser(
      id: id,
      tenantId: StoreContext.tenantId,
      storeId: StoreContext.storeId,
      email: trimmedEmail,
      fullName: fullName.trim(),
      phone: phone?.trim(),
      role: role,
      status: status,
    );
  }

  Future<void> updateUser({
    required String userId,
    String? fullName,
    String? phone,
    AppRole? role,
    bool? isActive,
    String? status,
  }) async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient!;
      await client.rpc('update_store_user', params: {
        'p_user_id': userId,
        'p_full_name': fullName,
        'p_phone': phone,
        'p_role_id': role?.id,
        'p_is_active': isActive,
        'p_status': status,
      });
    } else {
      await _db.updateStoreStaff(
        id: userId,
        fullName: fullName,
        phone: phone,
        roleId: role?.id,
        isActive: isActive,
      );
    }
    await _activity.log(action: 'user.updated', entity: 'user', entityId: userId);
  }

  Future<void> setUserPermissions(
    String userId,
    Map<String, bool> permissions,
  ) async {
    if (SupabaseConfig.isConfigured) {
      await supabaseClient!.rpc('set_user_permissions', params: {
        'p_user_id': userId,
        'p_permissions': permissions,
      });
    } else {
      await _db.setStoreStaffPermissions(userId, permissions);
    }
    await _activity.log(
      action: 'permissions.updated',
      entity: 'user',
      entityId: userId,
    );
  }

  Future<Map<String, bool>> getUserPermissionOverrides(String userId) async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient!;
      final rows = await client
          .from('user_permissions')
          .select('permission_id, granted')
          .eq('user_id', userId);
      return {
        for (final r in rows as List)
          r['permission_id'] as String: r['granted'] as bool,
      };
    }
    final staff = await _db.getStoreStaffRow(id: userId);
    if (staff?.customPermissionsJson == null) return {};
    return Map<String, bool>.from(
      (staff!.customPermissionsJson!.split(',').where((e) => e.isNotEmpty))
          .fold<Map<String, bool>>({}, (m, part) {
        final bits = part.split(':');
        if (bits.length == 2) m[bits[0]] = bits[1] == '1';
        return m;
      }),
    );
  }

  StoreUser _mapProfile(
    Map<String, dynamic> row,
    Map<String, bool> overrides,
  ) {
    return StoreUser(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String,
      storeId: row['store_id'] as String,
      email: row['email'] as String? ?? '',
      fullName: row['full_name'] as String? ?? '',
      phone: row['phone'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      role: AppRole.fromId(row['role_id'] as String?),
      isActive: row['is_active'] as bool? ?? true,
      status: row['status'] as String? ?? 'active',
      lastLoginAt: row['last_login_at'] != null
          ? DateTime.tryParse(row['last_login_at'].toString())
          : null,
      customPermissions: overrides,
    );
  }

  Future<Map<String, bool>> _fetchUserOverrides(
    SupabaseClient client,
    String userId,
  ) async {
    final rows = await client
        .from('user_permissions')
        .select('permission_id, granted')
        .eq('user_id', userId);
    return {
      for (final r in rows as List)
        r['permission_id'] as String: r['granted'] as bool,
    };
  }

  Set<String> _applyOverrides(Set<String> base, String encoded) {
    final result = Set<String>.from(base);
    for (final part in encoded.split(',')) {
      if (part.isEmpty) continue;
      final bits = part.split(':');
      if (bits.length != 2) continue;
      if (bits[1] == '1') {
        result.add(bits[0]);
      } else {
        result.remove(bits[0]);
      }
    }
    return result;
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(activityLoggerProvider),
  );
});

final storeUsersProvider = FutureProvider.autoDispose<List<StoreUser>>((ref) {
  return ref.watch(usersRepositoryProvider).listStoreUsers();
});
