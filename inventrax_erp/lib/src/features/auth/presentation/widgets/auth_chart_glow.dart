import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme/kulmis_auth_theme.dart';

/// Bottom analytics glow — static paint, no animation (stable 60 FPS).
class AuthChartGlow extends StatelessWidget {
  const AuthChartGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _AuthChartGlowPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _AuthChartGlowPainter extends CustomPainter {
  const _AuthChartGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final baseY = size.height * 0.82;
    final glow = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.1, 1.0),
        radius: 0.9,
        colors: [
          KulmisAuthTheme.teal.withValues(alpha: 0.22),
          KulmisAuthTheme.teal.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55),
      glow,
    );

    final linePaint = Paint()
      ..color = KulmisAuthTheme.teal.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          KulmisAuthTheme.teal.withValues(alpha: 0.28),
          KulmisAuthTheme.teal.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, baseY - 120, size.width, 120));

    final points = <Offset>[];
    for (var i = 0; i <= 24; i++) {
      final t = i / 24;
      final x = size.width * (0.04 + t * 0.92);
      final wave = math.sin(t * math.pi * 1.6) * 18;
      final trend = lerpDouble(28, 92, t)!;
      final y = baseY - trend - wave;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, baseY + 8)
      ..lineTo(points.first.dx, baseY + 8)
      ..close();
    canvas.drawPath(areaPath, fillPaint);

    final barPaint = Paint()..color = KulmisAuthTheme.teal.withValues(alpha: 0.35);
    final barW = size.width * 0.018;
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.08 + i * 0.055);
      final h = 18 + (i % 5) * 9.0;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baseY - h, barW, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(r, barPaint);
    }

    final dotPaint = Paint()..color = KulmisAuthTheme.teal;
    for (final p in [points[8], points[14], points[20]]) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(
        p,
        10,
        Paint()..color = KulmisAuthTheme.teal.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
