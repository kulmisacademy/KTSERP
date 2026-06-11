import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync_indicator_providers.dart';

/// QA overlay: queue depth + sync state (debug desktop builds only).
/// Disabled on web — the FutureProvider + Stack overlay retriggers MouseTracker.
final performanceHudEnabledProvider = Provider<bool>(
  (ref) => kDebugMode && !kIsWeb,
);

class PerformanceHud extends ConsumerWidget {
  const PerformanceHud({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(performanceHudEnabledProvider);
    if (!enabled) return child;

    final sync = ref.watch(syncIndicatorUiProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: 8,
          bottom: 8,
          child: RepaintBoundary(
            child: _HudChip(
              label: 'Q:${sync.pendingQueue} · ${sync.state.name}',
              color: sync.offlineMode ? Colors.orange : Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
