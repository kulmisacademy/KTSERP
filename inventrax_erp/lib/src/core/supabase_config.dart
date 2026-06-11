import 'env_config.dart';

/// Supabase connection from `.env` or `--dart-define`.
class SupabaseConfig {
  const SupabaseConfig._();

  static String get url => EnvConfig.supabaseUrl;
  static String get anonKey => EnvConfig.supabaseAnonKey;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
