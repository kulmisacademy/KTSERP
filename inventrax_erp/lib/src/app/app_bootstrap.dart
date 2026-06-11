import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/session_provider.dart';
import '../observability/connectivity_monitor.dart';
import '../observability/realtime_hub_provider.dart';
import '../sync/realtime_service.dart';
import '../sync/sync_scheduler.dart';

/// Starts background services without rebuilding [MaterialApp].
class AppServicesBootstrap extends ConsumerWidget {
  const AppServicesBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(
      sessionProvider.select((s) => s.isReady && s.isAuthenticated),
    );
    if (active) {
      ref.watch(connectivityProvider);
      ref.watch(syncSchedulerProvider);
      ref.watch(realtimeServiceProvider);
      if (!kIsWeb) {
        ref.watch(realtimeHubTickProvider);
      }
    }
    return const SizedBox.shrink();
  }
}
