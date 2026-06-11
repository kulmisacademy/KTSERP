import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'observability_hub.dart';

/// Bumps when [ObservabilityHub.setRealtime] changes so health UI refreshes.
final realtimeHubTickProvider = NotifierProvider<RealtimeHubTick, int>(
  RealtimeHubTick.new,
);

class RealtimeHubTick extends Notifier<int> {
  @override
  int build() {
    final hub = ObservabilityHub.instance;
    hub.onRealtimeChanged = () => state++;
    ref.onDispose(() {
      if (hub.onRealtimeChanged != null) {
        hub.onRealtimeChanged = null;
      }
    });
    return 0;
  }
}

final realtimeConnectionProvider = Provider<RealtimeConnectionState>((ref) {
  ref.watch(realtimeHubTickProvider);
  return ObservabilityHub.instance.realtimeState;
});
