import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';

/// Soft decorative orbit rings for atmospheric backgrounds.
class OrbitBackdrop extends StatelessWidget {
  const OrbitBackdrop({
    super.key,
    this.child,
    this.intensity = 1,
  });

  final Widget? child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      painter: _OrbitRingsPainter(
        pink: colors.brandPink.withValues(alpha: 0.18 * intensity),
        peach: colors.brandPeach.withValues(alpha: 0.28 * intensity),
        lavender: colors.brandLavender.withValues(alpha: 0.22 * intensity),
        ochre: colors.brandOchre.withValues(alpha: 0.16 * intensity),
        ink: colors.ink.withValues(alpha: 0.06 * intensity),
      ),
      child: child,
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  _OrbitRingsPainter({
    required this.pink,
    required this.peach,
    required this.lavender,
    required this.ochre,
    required this.ink,
  });

  final Color pink;
  final Color peach;
  final Color lavender;
  final Color ochre;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.82, size.height * 0.08);

    void ring(double radius, Color color, double stroke) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color;
      canvas.drawCircle(center, radius, paint);
    }

    ring(48, peach, 10);
    ring(86, lavender, 2.5);
    ring(128, pink, 1.5);
    ring(168, ochre, 3);

    // Partial arc near bottom-left for depth.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = ink
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * -0.05, size.height * 0.72),
        radius: 120,
      ),
      -0.4,
      math.pi * 0.7,
      false,
      arcPaint,
    );

    // Soft blob.
    final blob = Paint()..color = peach.withValues(alpha: 0.35);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.18),
      36,
      blob,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) => false;
}

/// Large day-index numeral used as a visual anchor on cards.
class BigDayMark extends StatelessWidget {
  const BigDayMark({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 72,
            height: 0.85,
            letterSpacing: -3,
            color: color.withValues(alpha: 0.18),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
