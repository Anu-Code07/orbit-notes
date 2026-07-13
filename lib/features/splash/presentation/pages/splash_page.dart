import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/made_by_credit.dart';
import 'package:orbit_notes/core/widgets/orbit_backdrop.dart';

/// Short travel-themed animated splash shown after the native splash.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _orbit;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _titleFade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _titleSlide = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic),
    );

    // Drop native splash on first frame so the orbit animation is immediate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      if (!mounted) return;
      _intro.forward();
    });
    Future<void>.delayed(const Duration(milliseconds: 850), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final prefs = getIt<AppPrefs>();
    final next = prefs.hasCompletedAuthGate ? '/' : '/login';
    context.go(next);
  }

  @override
  void dispose() {
    _intro.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: OrbitBackdrop(
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_intro, _orbit]),
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 168,
                      height: 168,
                      child: CustomPaint(
                        painter: _TravelSplashPainter(
                          ink: colors.ink,
                          orbit: colors.brandCoral,
                          orbitAngle: _orbit.value * math.pi * 2,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.lg),
                    Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _titleFade.value,
                        child: Column(
                          children: [
                            Text(
                              'ORBIT',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colors.brandCoral,
                                    letterSpacing: 3,
                                  ),
                            ),
                            SizedBox(height: spacing.xs),
                            Text(
                              'Orbit',
                              style: GoogleFonts.fraunces(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                                height: 1,
                                letterSpacing: -1.2,
                              ),
                            ),
                            SizedBox(height: spacing.sm),
                            Text(
                              'Collect days on the road',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: colors.body),
                            ),
                            SizedBox(height: spacing.sm),
                            const MadeByCredit(align: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TravelSplashPainter extends CustomPainter {
  _TravelSplashPainter({
    required this.ink,
    required this.orbit,
    required this.orbitAngle,
  });

  final Color ink;
  final Color orbit;
  final double orbitAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _paintOrbit(canvas, center, size.shortestSide * 0.42);
    _paintSuitcase(canvas, center, size.shortestSide * 0.34);
  }

  void _paintOrbit(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.35 + orbitAngle * 0.15);
    canvas.scale(1.15, 0.62);
    canvas.rotate(orbitAngle);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = orbit
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset.zero, radius, paint);
    // Small traveling “dot” on the ring.
    final dotPaint = Paint()..color = orbit;
    canvas.drawCircle(Offset(radius, 0), 5.5, dotPaint);
    canvas.restore();
  }

  void _paintSuitcase(Canvas canvas, Offset center, double width) {
    final height = width * 0.72;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    final fill = Paint()..color = ink;
    canvas.drawRRect(rrect, fill);

    final detail = Paint()
      ..color = const Color(0xFFFFFAF0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Handle.
    final handle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, rect.top - 8),
        width: width * 0.34,
        height: 16,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(handle, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, rect.top - 8),
          width: width * 0.22,
          height: 6,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFFFAF0),
    );

    // Straps.
    final strapW = width * 0.08;
    for (final dx in [-width * 0.18, width * 0.18]) {
      final strap = Rect.fromCenter(
        center: Offset(center.dx + dx, center.dy),
        width: strapW,
        height: height * 0.86,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(strap, const Radius.circular(3)),
        Paint()..color = ink.withValues(alpha: 0.85),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx + dx, center.dy),
            width: strapW * 1.35,
            height: strapW * 1.1,
          ),
          const Radius.circular(3),
        ),
        detail,
      );
    }

    // Corner guards.
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawCircle(corner, 5, detail);
    }
  }

  @override
  bool shouldRepaint(covariant _TravelSplashPainter oldDelegate) {
    return oldDelegate.orbitAngle != orbitAngle ||
        oldDelegate.ink != ink ||
        oldDelegate.orbit != orbit;
  }
}
