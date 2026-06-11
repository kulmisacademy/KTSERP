import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app/app.dart';
import 'src/core/env_config.dart';
import 'src/data/local/db_provider.dart';
import 'src/observability/monitoring_bootstrap.dart';
import 'src/sync/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  final dsn = EnvConfig.sentryDsn;
  if (dsn.isEmpty) {
    await _runApp();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.environment = EnvConfig.appEnv;
      options.debug = kDebugMode;
      options.tracesSampleRate = kDebugMode ? 0.0 : 0.2;
      options.attachScreenshot = true;
    },
    appRunner: () async {
      await _runApp();
    },
  );
}

Future<void> _runApp() async {
  _installMouseTrackerGuard();
  await MonitoringBootstrap.init();
  await initSupabaseIfConfigured();
  await openAppDatabase();
  runApp(
    SentryWidget(
      child: const ProviderScope(child: InventraXApp()),
    ),
  );
}

/// Suppresses recursive MouseTracker assertion spam on Flutter Web during dev.
void _installMouseTrackerGuard() {
  if (!kDebugMode) return;
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final text = details.exceptionAsString();
    if (text.contains('mouse_tracker.dart')) {
      return;
    }
    if (defaultOnError != null) {
      defaultOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };
}
