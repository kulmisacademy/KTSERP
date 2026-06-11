import 'env_config.dart';
import 'supabase_config.dart';

/// OpenAI configuration for AI Business Insights.
abstract final class AiConfig {
  static String get apiKey => EnvConfig.openAiApiKey;
  static String get model => EnvConfig.openAiModel;
  static String get apiBase => EnvConfig.openAiApiBase;

  static bool get useEdgeProxy =>
      EnvConfig.aiUseEdgeProxy && SupabaseConfig.isConfigured;

  /// Direct client key (dev only — prefer edge proxy in production).
  static bool get directKeyConfigured => apiKey.isNotEmpty;

  static bool get isConfigured => useEdgeProxy || directKeyConfigured;

  static int get timeoutMs => EnvConfig.apiTimeoutMs;

  static int get minRequestIntervalMs => 12_000;
}
