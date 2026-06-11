import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';

/// Fixed-height loading row — avoids layout jumps while AI responds.
class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key, required this.label});

  final String label;

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                final phase = (_controller.value + i * 0.2) % 1.0;
                final opacity = 0.35 + (phase < 0.5 ? phase : 1 - phase) * 1.3;
                return Opacity(opacity: opacity.clamp(0.35, 1.0), child: child);
              },
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
