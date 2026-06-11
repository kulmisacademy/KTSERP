import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shimmer-style placeholder blocks (no extra packages).
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
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
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final base = Theme.of(context).colorScheme.surfaceContainerHighest;
        final highlight = Theme.of(context).colorScheme.surface;
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(t * 2, 0),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
    if (kIsWeb) return box;
    return AppSkeleton(child: box);
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SkeletonBox(width: double.infinity, height: 120, borderRadius: 16),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 20),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 700 ? 2 : 1;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(
                    cols * 2,
                    (_) => SizedBox(
                      width: cols == 2 ? (c.maxWidth - 12) / 2 : c.maxWidth,
                      child: const SkeletonBox(
                        width: double.infinity,
                        height: 88,
                        borderRadius: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 20),
          sliver: SliverToBoxAdapter(
            child: SkeletonBox(
              width: double.infinity,
              height: 260,
              borderRadius: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class ListPageSkeleton extends StatelessWidget {
  const ListPageSkeleton({
    super.key,
    this.itemCount = 8,
    this.showHeader = true,
  });

  final int itemCount;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          const SkeletonBox(width: double.infinity, height: 72, borderRadius: 14),
          const SizedBox(height: 16),
          const SkeletonBox(width: double.infinity, height: 48, borderRadius: 12),
          const SizedBox(height: 16),
        ],
        for (var i = 0; i < itemCount; i++) ...[
          const SkeletonBox(width: double.infinity, height: 72, borderRadius: 12),
          if (i < itemCount - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

class PosCatalogSkeleton extends StatelessWidget {
  const PosCatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 650
                ? 3
                : 2;
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.82,
          ),
          itemCount: cross * 3,
          itemBuilder: (context, _) => const SkeletonBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 12,
          ),
        );
      },
    );
  }
}

class ReportsSkeleton extends StatelessWidget {
  const ReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListPageSkeleton(itemCount: 6, showHeader: true);
  }
}
