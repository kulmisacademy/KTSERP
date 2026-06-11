import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads configuration from `.env` (asset) with `--dart-define` fallback.
class EnvConfig {
  EnvConfig._();

  static var _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EnvConfig: .env not loaded ($e). Using dart-define / defaults.');
      }
    }
    _loaded = true;
  }

  static String _get(String key, {String defaultValue = ''}) {
    if (dotenv.isInitialized) {
      final fromEnv = dotenv.maybeGet(key);
      if (fromEnv != null && fromEnv.trim().isNotEmpty) return fromEnv.trim();
    }

    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
      case 'APP_NAME':
        return const String.fromEnvironment('APP_NAME', defaultValue: 'InventraX ERP');
      case 'APP_ENV':
        return const String.fromEnvironment('APP_ENV', defaultValue: 'development');
      case 'API_TIMEOUT':
        return const String.fromEnvironment('API_TIMEOUT', defaultValue: '30000');
      case 'ENABLE_LOGS':
        return const String.fromEnvironment('ENABLE_LOGS', defaultValue: 'true');
      case 'SENTRY_DSN':
        return const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      case 'POSTHOG_API_KEY':
        return const String.fromEnvironment('POSTHOG_API_KEY', defaultValue: '');
      case 'POSTHOG_HOST':
        return const String.fromEnvironment(
          'POSTHOG_HOST',
          defaultValue: 'https://app.posthog.com',
        );
      case 'OPENAI_API_KEY':
        return const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
      case 'OPENAI_MODEL':
        return const String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
      case 'OPENAI_API_BASE':
        return const String.fromEnvironment(
          'OPENAI_API_BASE',
          defaultValue: 'https://api.openai.com/v1',
        );
      case 'AI_USE_EDGE_PROXY':
        return const String.fromEnvironment('AI_USE_EDGE_PROXY', defaultValue: 'true');
      default:
        return defaultValue;
    }
  }

  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY');
  static String get appName => _get('APP_NAME', defaultValue: 'InventraX ERP');
  static String get appEnv => _get('APP_ENV', defaultValue: 'development');
  static int get apiTimeoutMs => int.tryParse(_get('API_TIMEOUT')) ?? 30000;
  static bool get enableLogs => _get('ENABLE_LOGS').toLowerCase() != 'false';
  static String get sentryDsn => _get('SENTRY_DSN');
  static String get posthogApiKey => _get('POSTHOG_API_KEY');
  static String get posthogHost => _get('POSTHOG_HOST');

  static bool get isProduction => appEnv == 'production';

  static String get openAiApiKey => _get('OPENAI_API_KEY');
  static String get openAiModel => _get('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');
  static String get openAiApiBase => _get('OPENAI_API_BASE', defaultValue: 'https://api.openai.com/v1');

  /// When true, OpenAI calls go through Supabase Edge Function (recommended).
  static bool get aiUseEdgeProxy =>
      _get('AI_USE_EDGE_PROXY', defaultValue: 'true').toLowerCase() != 'false';
}
