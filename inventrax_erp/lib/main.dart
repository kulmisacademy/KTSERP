import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app/boot_gate.dart';
import 'src/core/env_config.dart';
import 'src/core/startup/startup_profiler.dart';

Future<void> main() async {
  StartupProfiler.mark('main() start');
  WidgetsFlutterBinding.ensureInitialized();
  StartupProfiler.mark('flutter binding ready');

  // Only the env load is awaited before runApp — everything else (Supabase,
  // DB, monitoring) is initialized in the background inside [BootGate] so the
  // first frame paints immediately instead of waiting on network/IO.
  await StartupProfiler.track('env load', EnvConfig.load);

  final dsn = EnvConfig.sentryDsn;
  if (dsn.isEmpty) {
    _runApp();
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
    appRunner: _runApp,
  );
}

void _runApp() {
  _installMouseTrackerGuard();
  StartupProfiler.mark('runApp(BootGate)');
  runApp(const BootGate());
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
