import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/startup/startup_profiler.dart';
import '../features/auth/application/session_provider.dart';
import '../observability/connectivity_monitor.dart';
import '../observability/realtime_hub_provider.dart';
import '../sync/realtime_service.dart';
import '../sync/sync_scheduler.dart';

/// Starts background services without rebuilding [MaterialApp].
///
/// Realtime subscriptions are intentionally delayed a few seconds after the UI
/// is on screen so they never compete with first paint / dashboard render.
class AppServicesBootstrap extends ConsumerStatefulWidget {
  const AppServicesBootstrap({super.key});

  @override
  ConsumerState<AppServicesBootstrap> createState() =>
      _AppServicesBootstrapState();
}

class _AppServicesBootstrapState extends ConsumerState<AppServicesBootstrap> {
  static const _realtimeDelay = Duration(seconds: 3);
  Timer? _delayTimer;
  bool _realtimeReady = false;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(_realtimeDelay, () {
      if (!mounted) return;
      StartupProfiler.mark('realtime enabled (post-UI delay)');
      setState(() => _realtimeReady = true);
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(
      sessionProvider.select((s) => s.isReady && s.isAuthenticated),
    );
    if (active) {
      ref.watch(connectivityProvider);
      ref.watch(syncSchedulerProvider);
      // Realtime websocket only after the UI has settled.
      if (_realtimeReady) {
        ref.watch(realtimeServiceProvider);
        if (!kIsWeb) {
          ref.watch(realtimeHubTickProvider);
        }
      }
    }
    return const SizedBox.shrink();
  }
}
