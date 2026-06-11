import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../core/env_config.dart';
import 'observability_hub.dart';

/// Production monitoring hooks (Sentry / PostHog).
///
/// Configure via `.env` or `--dart-define`:
/// - SENTRY_DSN
/// - POSTHOG_API_KEY
/// - POSTHOG_HOST (optional, default https://app.posthog.com)
class MonitoringBootstrap {
  MonitoringBootstrap._();

  static var _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final sentryActive = EnvConfig.sentryDsn.isNotEmpty;

    if (sentryActive) {
      ObservabilityHub.instance.log(
        'monitoring',
        'Sentry active (org/project via SENTRY_DSN)',
      );
    }

    if (EnvConfig.posthogApiKey.isNotEmpty) {
      ObservabilityHub.instance.log(
        'monitoring',
        'PostHog key configured (analytics events via MonitoringService)',
      );
    }

    // When Sentry is initialized in main.dart, it owns global error handlers.
    if (!sentryActive) {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        MonitoringService.captureException(
          details.exception,
          stackTrace: details.stack,
          hint: 'FlutterError',
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        MonitoringService.captureException(error, stackTrace: stack);
        return true;
      };
    }
  }
}

class MonitoringService {
  MonitoringService._();

  static void captureException(
    Object error, {
    StackTrace? stackTrace,
    String? hint,
  }) {
    ObservabilityHub.instance.log(
      'error',
      '${hint ?? 'exception'}: $error',
      level: ObservabilityLevel.error,
    );
    if (EnvConfig.sentryDsn.isNotEmpty) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'context': hint}) : null,
      );
    } else if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: hint);
    }
  }

  static void trackEvent(String name, [Map<String, Object?>? properties]) {
    if (EnvConfig.posthogApiKey.isEmpty) return;
    if (kDebugMode) {
      debugPrint('PostHog event: $name $properties');
    }
  }

  static void trackScreen(String screenName) {
    trackEvent('screen_view', {'screen': screenName});
  }
}
