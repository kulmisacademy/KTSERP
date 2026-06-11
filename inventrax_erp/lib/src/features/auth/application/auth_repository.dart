import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:uuid/uuid.dart';

import '../../../core/phone/phone_normalizer.dart';
import '../../../core/store/store_branding.dart';
import '../../../core/store_context.dart';
import '../../../core/supabase_config.dart';
import '../../../data/local/app_database.dart';
import '../../../core/money/currency_symbol.dart';
import '../../../sync/supabase_bootstrap.dart';
import '../domain/app_role.dart';
import '../domain/registration_data.dart';
import '../../ai_insights/data/ai_insights_cache.dart';
import '../../users/domain/permission_registry.dart';
import '../../users/domain/permission_service.dart';
import 'auth_exception.dart';
import 'password_validator.dart';
import 'secure_session_store.dart';

const _uuid = Uuid();
const _activeSessionId = 'active';

String _resolveSessionStoreName(String? name) {
  final t = name?.trim();
  if (t != null && t.isNotEmpty && t != 'My Store') return t;
  final ctx = StoreContext.storeName?.trim();
  if (ctx != null && ctx.isNotEmpty && ctx != 'My Store') return ctx;
  return t ?? ctx ?? 'My Store';
}

class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.tenantId,
    required this.storeId,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.storeName,
    required this.role,
    this.permissions = const {},
  });

  final String tenantId;
  final String storeId;
  final String userId;
  final String email;
  final String displayName;
  final String storeName;
  final AppRole role;
  final Set<String> permissions;
}

class AuthRepository {
  AuthRepository(this._db, {SecureSessionStore? secure})
      : _secure = secure ?? SecureSessionStore();

  final AppDatabase _db;
  final SecureSessionStore _secure;

  Future<AuthSessionSnapshot?> restoreSession() async {
    // Fast path: local Drift session — render shell without waiting on network.
    final local = await _restoreFromLocalActiveSession(deferAccountingSeed: true);
    if (local != null) {
      unawaited(_refreshSessionFromCloud());
      return local;
    }

    return _restoreFromSupabase();
  }

  Future<AuthSessionSnapshot?> _restoreFromLocalActiveSession({
    bool deferAccountingSeed = false,
  }) async {
    final row = await _db.getActiveSession();
    if (row == null || row.email == null) return null;

    final role = AppRole.fromId(row.role);
    final perms = InventraxPermissionRegistry.templateForRole(role);
    final snapshot = AuthSessionSnapshot(
      tenantId: row.tenantId,
      storeId: row.storeId,
      userId: row.userId ?? _uuid.v4(),
      email: row.email!,
      displayName: row.displayName ?? row.email!.split('@').first,
      storeName: _resolveSessionStoreName(row.storeName),
      role: role,
      permissions: perms,
    );
    StoreContext.apply(
      tenantId: snapshot.tenantId,
      storeId: snapshot.storeId,
      userId: snapshot.userId,
      email: snapshot.email,
      displayName: snapshot.displayName,
      storeName: snapshot.storeName,
      role: snapshot.role,
      permissions: snapshot.permissions,
    );
    if (deferAccountingSeed) {
      unawaited(_db.ensureAccountingSeeded(
        tenantId: snapshot.tenantId,
        storeId: snapshot.storeId,
      ));
      unawaited(_db.cleanupForeignTenantData(
        tenantId: snapshot.tenantId,
        storeId: snapshot.storeId,
      ));
    } else {
      await _db.ensureAccountingSeeded(
        tenantId: snapshot.tenantId,
        storeId: snapshot.storeId,
      );
      await _db.cleanupForeignTenantData(
        tenantId: snapshot.tenantId,
        storeId: snapshot.storeId,
      );
    }
    return snapshot;
  }

  Future<AuthSessionSnapshot?> _restoreFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return null;
    final client = supabaseClient;
    if (client == null) return null;

    try {
      var session = client.auth.currentSession;
      if (session == null) {
        final stored = await _secure.readRefreshToken();
        if (stored != null && stored.isNotEmpty) {
          await client.auth.recoverSession(stored);
          session = client.auth.currentSession;
        }
      }
      if (session == null) return null;

      final profile = await _fetchProfile(client, session.user.id);
      if (profile == null) return null;

      final enriched = await _enrichWithPermissions(profile);
      await _hydrateLocalStoreSettingsFromCloud(client, enriched);
      await _persistLocal(enriched, rememberMe: true);
      return enriched;
    } catch (e) {
      if (kDebugMode) debugPrint('Supabase session restore failed: $e');
      return null;
    }
  }

  /// Background refresh after fast local restore (permissions, settings, tokens).
  Future<void> _refreshSessionFromCloud() async {
    if (!SupabaseConfig.isConfigured) return;
    final client = supabaseClient;
    if (client == null) return;

    try {
      var session = client.auth.currentSession;
      if (session == null) {
        final stored = await _secure.readRefreshToken();
        if (stored == null || stored.isEmpty) return;
        await client.auth.recoverSession(stored);
        session = client.auth.currentSession;
      }
      if (session == null) return;

      final profile = await _fetchProfile(client, session.user.id);
      if (profile == null) return;

      final enriched = await _enrichWithPermissions(profile);
      await _hydrateLocalStoreSettingsFromCloud(client, enriched);
      await _persistLocal(enriched, rememberMe: true);
    } catch (e) {
      if (kDebugMode) debugPrint('Background session refresh failed: $e');
    }
  }

  Future<AuthSessionSnapshot> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final trimmed = email.trim().toLowerCase();
    if (password.isEmpty) {
      throw AuthException('Password is required');
    }

    if (!SupabaseConfig.isConfigured) {
      return _localDevSignIn(trimmed, rememberMe: rememberMe);
    }

    final client = supabaseClient!;
    try {
      final res = await client.auth.signInWithPassword(
        email: trimmed,
        password: password,
      );
      final session = res.session;
      if (session == null) {
        throw AuthException('Sign in failed. Please try again.');
      }

      if (rememberMe) {
        await _secure.saveRefreshToken(jsonEncode(session.toJson()));
        await _secure.saveRememberEmail(trimmed);
      } else {
        await _secure.saveRefreshToken(null);
      }

      var profile = await _fetchProfile(client, session.user.id);
      profile ??= await _tryRegisterPendingLocal(trimmed, session.user.id);

      if (profile == null) {
        throw AuthException(
          'No store linked to this account. Register your store first.',
          code: 'no_profile',
        );
      }

      final enriched = await _enrichWithPermissions(profile);
      await _hydrateLocalStoreSettingsFromCloud(client, enriched);
      await _persistLocal(enriched, rememberMe: rememberMe);
      await _recordLoginRemote();
      return enriched;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.fromSupabase(e);
    }
  }

  Future<AuthSessionSnapshot> registerStore(RegistrationData data) async {
    final email = data.email.trim().toLowerCase();
    final pwdCheck = PasswordValidator.validate(data.password);
    if (!pwdCheck.isValid) {
      throw AuthException(pwdCheck.message ?? 'Invalid password');
    }
    if (data.storeName.trim().isEmpty) {
      throw AuthException('Store name is required');
    }
    if (data.ownerName.trim().isEmpty) {
      throw AuthException('Owner name is required');
    }
    final phoneNorm = PhoneNormalizer.normalizeSomali(data.phone);
    if (!phoneNorm.ok) {
      throw AuthException(phoneNorm.error ?? 'Valid phone number is required');
    }
    final phone = phoneNorm.e164;

    if (!SupabaseConfig.isConfigured) {
      return _localRegister(data, email);
    }

    final client = supabaseClient!;
    try {
      final auth = await _authenticateForRegistration(
        client,
        email: email,
        password: data.password,
        ownerName: data.ownerName.trim(),
        phone: phone,
      );
      final session = auth.session;
      final userId = auth.userId;

      await _secure.saveRefreshToken(jsonEncode(session.toJson()));
      await _secure.saveRememberEmail(email);

      final tax = data.taxNumber?.trim();
      final result = await client.rpc(
        'register_store',
        params: {
          'p_store_name': data.storeName.trim(),
          'p_business_type': data.businessType.trim(),
          'p_country': data.country.trim().isEmpty ? 'Somalia' : data.country.trim(),
          'p_currency': data.currencyCode.trim().isEmpty
              ? 'USD'
              : data.currencyCode.trim().toUpperCase(),
          'p_address': data.address.trim().isEmpty ? null : data.address.trim(),
          'p_owner_name': data.ownerName.trim(),
          'p_phone': phone,
          'p_tax_number': (tax == null || tax.isEmpty) ? null : tax,
        },
      ) as Map<String, dynamic>;

      final tenantId = result['tenant_id'] as String;
      final storeId = result['store_id'] as String;
      final role = AppRole.fromId(result['role_id'] as String?);
      final storeName = result['store_name'] as String? ?? data.storeName.trim();

      var snapshot = AuthSessionSnapshot(
        tenantId: tenantId,
        storeId: storeId,
        userId: userId,
        email: email,
        displayName: data.ownerName.trim(),
        storeName: storeName,
        role: role,
      );
      snapshot = await _enrichWithPermissions(snapshot);

      await _seedLocalStoreSettings(data, snapshot);
      await _persistLocal(snapshot, rememberMe: true);
      return snapshot;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException.fromSupabase(e);
    }
  }

  Future<void> signOut() async {
    final tenantId = StoreContext.tenantId;
    final storeId = StoreContext.storeId;
    if (StoreContext.isSuperAdmin && SupabaseConfig.isConfigured) {
      try {
        await supabaseClient?.rpc('inventrax_platform_end_impersonation');
      } catch (_) {}
    }
    if (SupabaseConfig.isConfigured) {
      try {
        await supabaseClient?.auth.signOut();
      } catch (_) {}
    }
    if (storeId.isNotEmpty && storeId != StoreContext.defaultStoreId) {
      await _db.purgeLocalDataForScope(tenantId: tenantId, storeId: storeId);
    }
    await _db.purgeAllSyncQueue();
    await AiInsightsCache().clearExceptStore('');
    await _secure.clear();
    await _db.clearActiveSession();
    StoreContext.reset();
  }

  Future<AuthSessionSnapshot> _localRegister(
    RegistrationData data,
    String email,
  ) async {
    final tenantId = _uuid.v4();
    final storeId = _uuid.v4();
    final userId = _uuid.v4();
    final snapshot = AuthSessionSnapshot(
      tenantId: tenantId,
      storeId: storeId,
      userId: userId,
      email: email,
      displayName: data.ownerName.trim(),
      storeName: data.storeName.trim(),
      role: AppRole.storeOwner,
      permissions: InventraxPermissionRegistry.templateForRole(AppRole.storeOwner),
    );
    await _seedLocalStoreSettings(data, snapshot);
    await _persistLocal(snapshot, rememberMe: true);
    return snapshot;
  }

  Future<AuthSessionSnapshot> _localDevSignIn(
    String email, {
    required bool rememberMe,
  }) async {
    final row = await _db.getActiveSession();
    if (row != null && row.email == email) {
      final restored = await restoreSession();
      if (restored != null) return restored;
      final role = AppRole.fromId(row.role);
      return AuthSessionSnapshot(
        tenantId: row.tenantId,
        storeId: row.storeId,
        userId: row.userId ?? _uuid.v4(),
        email: email,
        displayName: row.displayName ?? email.split('@').first,
        storeName: _resolveSessionStoreName(row.storeName),
        role: role,
        permissions: InventraxPermissionRegistry.templateForRole(role),
      );
    }

    final snapshot = AuthSessionSnapshot(
      tenantId: StoreContext.defaultTenantId,
      storeId: StoreContext.defaultStoreId,
      userId: _uuid.v4(),
      email: email,
      displayName: email.split('@').first,
      storeName: 'My Store',
      role: AppRole.storeOwner,
      permissions: InventraxPermissionRegistry.templateForRole(AppRole.storeOwner),
    );
    await _persistLocal(snapshot, rememberMe: rememberMe);
    return snapshot;
  }

  Future<AuthSessionSnapshot?> _fetchProfile(
    SupabaseClient client,
    String userId,
  ) async {
    final row = await client
        .from('profiles')
        .select('tenant_id, store_id, role_id, full_name, email')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;

    final storeRow = await client
        .from('stores')
        .select('name')
        .eq('id', row['store_id'] as String)
        .maybeSingle();
    final storeName = storeRow?['name'] as String?;

    final role = AppRole.fromId(row['role_id'] as String?);
    final perms = await _loadPermissions(userId, role);
    return AuthSessionSnapshot(
      tenantId: row['tenant_id'] as String,
      storeId: row['store_id'] as String,
      userId: userId,
      email: (row['email'] as String?) ?? '',
      displayName: (row['full_name'] as String?) ?? '',
      storeName: _resolveSessionStoreName(storeName),
      role: role,
      permissions: perms,
    );
  }

  Future<AuthSessionSnapshot> _enrichWithPermissions(
    AuthSessionSnapshot snapshot,
  ) async {
    final perms = await _loadPermissions(snapshot.userId, snapshot.role);
    return AuthSessionSnapshot(
      tenantId: snapshot.tenantId,
      storeId: snapshot.storeId,
      userId: snapshot.userId,
      email: snapshot.email,
      displayName: snapshot.displayName,
      storeName: snapshot.storeName,
      role: snapshot.role,
      permissions: perms,
    );
  }

  Future<Set<String>> _loadPermissions(String userId, AppRole role) async {
    if (SupabaseConfig.isConfigured) {
      final client = supabaseClient;
      if (client != null) {
        try {
          final res = await client.rpc(
            'inventrax_effective_permissions',
            params: {'p_user_id': userId},
          );
          final parsed = PermissionService.parseList(res as List?);
          if (parsed.isNotEmpty) return _normalizeGrants(parsed);
        } catch (e) {
          if (kDebugMode) debugPrint('_loadPermissions: $e');
        }
        try {
          final roleRow = await client
              .from('roles')
              .select('permissions')
              .eq('id', role.id)
              .maybeSingle();
          if (roleRow != null) {
            final raw = roleRow['permissions'] as List?;
            return _normalizeGrants(PermissionService.parseList(raw));
          }
        } catch (_) {}
      }
    }
    return InventraxPermissionRegistry.templateForRole(role);
  }

  /// Server / stored grants are authoritative — never union role templates (RBAC hardening).
  Set<String> _normalizeGrants(Set<String> grants) =>
      InventraxPermissionRegistry.normalizeGrants(grants);

  Future<void> _recordLoginRemote() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await supabaseClient?.rpc('record_login');
    } catch (_) {}
  }

  Future<AuthSessionSnapshot?> _tryRegisterPendingLocal(
    String email,
    String userId,
  ) async {
    return null;
  }

  /// New signup, or existing Auth user finishing store setup (no profile yet).
  Future<({Session session, String userId})> _authenticateForRegistration(
    SupabaseClient client, {
    required String email,
    required String password,
    required String ownerName,
    required String phone,
  }) async {
    Session? session;
    String? userId;

    try {
      final signUp = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': ownerName,
          'phone': phone,
        },
      );
      session = signUp.session;
      userId = signUp.user?.id;
    } catch (e) {
      if (!_isExistingAuthUserError(e)) {
        if (e is AuthException) rethrow;
        throw AuthException.fromSupabase(e);
      }
    }

    if (session != null && userId != null) {
      return (session: session, userId: userId);
    }

    try {
      final signIn = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      session = signIn.session;
      userId = signIn.user?.id ?? userId;
    } catch (e) {
      throw AuthException(
        'This email already has a login. Use the exact same password you use on the Sign in page, or tap Forgot password.',
        code: 'existing_account',
      );
    }

    if (session == null || userId == null) {
      throw AuthException(
        'Confirm your email in Supabase, then return here to finish store setup.',
        code: 'confirm_email',
      );
    }

    final existing = await _fetchProfile(client, userId);
    if (existing != null) {
      throw AuthException(
        'This account already has a store. Sign in to open your dashboard.',
        code: 'already_registered',
      );
    }

    return (session: session, userId: userId);
  }

  bool _isExistingAuthUserError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('already registered') ||
        text.contains('already exists') ||
        text.contains('user already') ||
        text.contains('email address has already been');
  }

  Future<void> _seedLocalStoreSettings(
    RegistrationData data,
    AuthSessionSnapshot snapshot,
  ) async {
    final storeName = data.storeName.trim().isNotEmpty
        ? data.storeName.trim()
        : snapshot.storeName;
    final currency = data.currencyCode.trim().isEmpty
        ? 'USD'
        : data.currencyCode.trim().toUpperCase();
    final country =
        data.country.trim().isEmpty ? 'Somalia' : data.country.trim();
    final email = data.email.trim().toLowerCase();
    final phoneNorm = PhoneNormalizer.normalizeSomali(data.phone);
    final phone = phoneNorm.ok ? phoneNorm.e164 : data.phone.trim();

    await _db.upsertStoreSettings(
      StoreSettingsCompanion.insert(
        storeId: snapshot.storeId,
        tenantId: snapshot.tenantId,
        storeName: storeName,
        businessType: Value(
          data.businessType.trim().isEmpty ? 'Retail' : data.businessType.trim(),
        ),
        phone: Value(phone.isEmpty ? null : phone),
        email: Value(email.isEmpty ? null : email),
        address: Value(data.address.trim().isEmpty ? null : data.address.trim()),
        taxNumber: Value(
          data.taxNumber?.trim().isEmpty ?? true ? null : data.taxNumber!.trim(),
        ),
        country: Value(country),
        currencyCode: Value(currency),
        currencySymbol: Value(currencySymbolFor(currency)),
        localeCode: const Value('en'),
        receiptHeader: Value(storeName),
        invoiceCompactMode: const Value(true),
        planName: const Value('Free Trial'),
        updatedAt: Value(DateTime.now()),
      ),
    );

    StoreBranding.applyToSession(
      await _db.getStoreSettings(storeId: snapshot.storeId),
    );

    await _syncStoreBrandingToCloud(
      snapshot: snapshot,
      storeName: storeName,
      data: data,
      phone: phone,
      email: email,
      currency: currency,
    );
  }

  Future<void> _hydrateLocalStoreSettingsFromCloud(
    SupabaseClient client,
    AuthSessionSnapshot snapshot,
  ) async {
    try {
      final row = await client
          .from('stores')
          .select(
            'name, phone, email, address, country, currency_code, tax_number, '
            'logo_url, business_type, invoice_footer, locale_code',
          )
          .eq('id', snapshot.storeId)
          .eq('tenant_id', snapshot.tenantId)
          .maybeSingle();
      if (row == null) return;

      final tenantRow = await client
          .from('tenants')
          .select('country, currency_code')
          .eq('id', snapshot.tenantId)
          .maybeSingle();

      final existing =
          await _db.getStoreSettings(storeId: snapshot.storeId);
      if (existing != null) {
        final age = DateTime.now().difference(existing.updatedAt);
        if (age < const Duration(minutes: 5) &&
            existing.storeName.isNotEmpty &&
            existing.storeName != 'My Store') {
          return;
        }
      }

      final currency = ((row['currency_code'] as String?) ??
              tenantRow?['currency_code'] as String? ??
              existing?.currencyCode ??
              'USD')
          .toUpperCase();
      final country = (row['country'] as String?)?.trim().isNotEmpty == true
          ? (row['country'] as String).trim()
          : ((tenantRow?['country'] as String?)?.trim().isNotEmpty == true
              ? (tenantRow!['country'] as String).trim()
              : (existing?.country ?? 'Somalia'));

      await _db.upsertStoreSettings(
        StoreSettingsCompanion.insert(
          storeId: snapshot.storeId,
          tenantId: snapshot.tenantId,
          storeName: _pickStoreName(
            row['name'] as String?,
            existing?.storeName,
            snapshot.storeName,
          ),
          businessType: Value(
            (row['business_type'] as String?) ??
                existing?.businessType ??
                'Retail',
          ),
          phone: Value(
            (row['phone'] as String?) ?? existing?.phone,
          ),
          email: Value(
            (row['email'] as String?)?.trim().isNotEmpty == true
                ? row['email'] as String
                : (existing?.email ?? snapshot.email),
          ),
          address: Value(row['address'] as String? ?? existing?.address),
          country: Value(country),
          taxNumber: Value(row['tax_number'] as String? ?? existing?.taxNumber),
          currencyCode: Value(currency),
          currencySymbol: Value(currencySymbolFor(currency)),
          localeCode: Value(
            row['locale_code'] as String? ?? existing?.localeCode ?? 'en',
          ),
          receiptHeader: Value(
            _pickStoreName(
              row['name'] as String?,
              existing?.receiptHeader,
              snapshot.storeName,
            ),
          ),
          invoiceFooter: Value(
            row['invoice_footer'] as String? ?? existing?.invoiceFooter,
          ),
          logoUrl: Value(row['logo_url'] as String? ?? existing?.logoUrl),
          logoLocalPath: Value(existing?.logoLocalPath),
          invoiceCompactMode: Value(existing?.invoiceCompactMode ?? true),
          planName: Value(existing?.planName ?? 'Free Trial'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Hydrate store settings deferred: $e');
    }
  }

  String _pickStoreName(String? cloud, String? local, String session) {
    for (final candidate in [cloud, local, session]) {
      final t = candidate?.trim();
      if (t != null && t.isNotEmpty && t != 'My Store') return t;
    }
    return _resolveSessionStoreName(cloud ?? local ?? session);
  }

  Future<void> _syncStoreBrandingToCloud({
    required AuthSessionSnapshot snapshot,
    required String storeName,
    required RegistrationData data,
    required String phone,
    required String email,
    required String currency,
  }) async {
    if (!SupabaseConfig.isConfigured) return;
    final client = supabaseClient;
    if (client == null) return;

    try {
      await client.from('stores').update({
        'name': storeName,
        'phone': phone,
        'email': email,
        'address': data.address.trim().isEmpty ? null : data.address.trim(),
        'country': data.country.trim().isEmpty ? 'Somalia' : data.country.trim(),
        'currency_code': currency,
        'tax_number': data.taxNumber?.trim().isEmpty ?? true
            ? null
            : data.taxNumber!.trim(),
        'business_type': data.businessType.trim().isEmpty
            ? 'Retail'
            : data.businessType.trim(),
      }).eq('id', snapshot.storeId).eq('tenant_id', snapshot.tenantId);

      await client.from('tenants').update({
        'name': storeName,
        'country': data.country.trim().isEmpty ? 'Somalia' : data.country.trim(),
        'currency_code': currency,
      }).eq('id', snapshot.tenantId);
    } catch (e) {
      if (kDebugMode) debugPrint('Cloud branding sync deferred: $e');
    }
  }

  /// Switch active tenant/store locally (e.g. super-admin impersonation).
  Future<void> applyStoreContext({
    required String tenantId,
    required String storeId,
    required String storeName,
    AppRole role = AppRole.superAdmin,
    Set<String>? permissions,
  }) async {
    final perms =
        permissions ?? InventraxPermissionRegistry.templateForRole(role);
    final snapshot = AuthSessionSnapshot(
      tenantId: tenantId,
      storeId: storeId,
      userId: StoreContext.userId ?? _uuid.v4(),
      email: StoreContext.userEmail ?? '',
      displayName: StoreContext.displayName ?? 'Admin',
      storeName: storeName,
      role: role,
      permissions: perms,
    );
    await _persistLocal(snapshot, rememberMe: true);
  }

  Future<void> _persistLocal(
    AuthSessionSnapshot snapshot, {
    required bool rememberMe,
  }) async {
    StoreContext.apply(
      tenantId: snapshot.tenantId,
      storeId: snapshot.storeId,
      userId: snapshot.userId,
      email: snapshot.email,
      displayName: snapshot.displayName,
      storeName: snapshot.storeName,
      role: snapshot.role,
      permissions: _normalizeGrants(snapshot.permissions),
    );

    await _db.ensureAccountingSeeded(
      tenantId: snapshot.tenantId,
      storeId: snapshot.storeId,
    );
    await _db.saveActiveSession(
      AppSessionsCompanion.insert(
        id: _activeSessionId,
        tenantId: snapshot.tenantId,
        storeId: snapshot.storeId,
        userId: Value(snapshot.userId),
        email: Value(snapshot.email),
        displayName: Value(snapshot.displayName),
        storeName: Value(snapshot.storeName),
        role: Value(snapshot.role.id),
        rememberMe: Value(rememberMe),
        lastLoginAt: Value(DateTime.now()),
      ),
    );

    await _db.cleanupForeignTenantData(
      tenantId: snapshot.tenantId,
      storeId: snapshot.storeId,
    );

    final settings = await _db.getStoreSettings(storeId: snapshot.storeId);
    StoreBranding.applyToSession(settings);
  }
}
