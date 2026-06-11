import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env_config.dart';
import '../core/supabase_config.dart';

/// Initializes Supabase when URL + anon key are in `.env` or dart-define.
Future<void> initSupabaseIfConfigured() async {
  if (!SupabaseConfig.isConfigured) {
    if (kDebugMode && EnvConfig.enableLogs) {
      debugPrint(
        'Supabase: not configured (set SUPABASE_URL and SUPABASE_ANON_KEY in .env)',
      );
    }
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  if (kDebugMode && EnvConfig.enableLogs) {
    debugPrint('Supabase: initialized (${EnvConfig.appEnv})');
  }
}

SupabaseClient? get supabaseClient {
  if (!SupabaseConfig.isConfigured) return null;
  return Supabase.instance.client;
}
