import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/store_context.dart';
import '../../../core/tenant/tenant_scope_cleanup.dart';
import '../../../data/local/db_provider.dart';
import '../../../sync/sync_service.dart';
import '../../ai_insights/application/monthly_ai_report_service.dart';
import '../domain/registration_data.dart';

import 'auth_repository.dart';



class SessionState {

  const SessionState({

    required this.isReady,

    required this.isAuthenticated,

    this.email,

    this.storeName,

    this.role,

  });



  final bool isReady;

  final bool isAuthenticated;

  final String? email;

  final String? storeName;

  final String? role;



  static const booting = SessionState(isReady: false, isAuthenticated: false);

}



final authRepositoryProvider = Provider<AuthRepository>((ref) {

  return AuthRepository(ref.watch(appDatabaseProvider));

});



class SessionController extends Notifier<SessionState> {

  AuthRepository get _auth => ref.read(authRepositoryProvider);



  @override

  SessionState build() {

    ref.watch(authRepositoryProvider);

    Future.microtask(_restore);

    return SessionState.booting;

  }



  Future<void> _restore() async {

    final snapshot = await _auth.restoreSession();

    if (snapshot != null) {

      state = SessionState(

        isReady: true,

        isAuthenticated: true,

        email: snapshot.email,

        storeName: snapshot.storeName,

        role: snapshot.role.id,

      );

      if (StoreContext.isLoggedIn) {
        _startBackgroundServices(ref);
      }

    } else {

      StoreContext.reset();

      state = const SessionState(isReady: true, isAuthenticated: false);

    }

  }



  Future<void> signIn({

    required String email,

    required String password,

    bool rememberMe = true,

  }) async {

    final snapshot = await _auth.signIn(

      email: email,

      password: password,

      rememberMe: rememberMe,

    );

    state = SessionState(

      isReady: true,

      isAuthenticated: true,

      email: snapshot.email,

      storeName: snapshot.storeName,

      role: snapshot.role.id,

    );

    _startBackgroundServices(ref);

  }

  /// Sync, AI, and analytics — never block shell render.
  void _startBackgroundServices(Ref ref) {
    unawaited(
      ref.read(syncWorkerProvider.notifier).fullSync(forceFullPull: true),
    );
    unawaited(ref.read(monthlyAiReportServiceProvider).runIfNeeded());
  }

  Future<void> registerStore(RegistrationData data) async {
    final snapshot = await _auth.registerStore(data);

    state = SessionState(
      isReady: true,
      isAuthenticated: true,
      email: snapshot.email,
      storeName: snapshot.storeName,
      role: snapshot.role.id,
    );

    _startBackgroundServices(ref);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const SessionState(isReady: true, isAuthenticated: false);
    // Defer invalidation — doing it inside signOut() causes a Riverpod circular
    // dependency (storeSettingsProvider ↔ sessionProvider via activeStoreScope).
    Future.microtask(() => TenantScopeCleanup.invalidateStoreScopedProviders(ref));
  }

  void refreshStoreName(String? storeName) {
    if (!state.isAuthenticated) return;
    state = SessionState(
      isReady: state.isReady,
      isAuthenticated: state.isAuthenticated,
      email: state.email,
      storeName: storeName ?? state.storeName,
      role: state.role,
    );
  }

}



final sessionProvider = NotifierProvider<SessionController, SessionState>(

  SessionController.new,

);


