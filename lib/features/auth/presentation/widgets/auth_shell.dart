import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';

/// Atmospheric auth canvas: drifting color fields + slow orbit rings.
class AuthAtmosphere extends StatefulWidget {
  const AuthAtmosphere({
    super.key,
    required this.child,
    this.accent = AuthAccent.coral,
  });

  final Widget child;
  final AuthAccent accent;

  @override
  State<AuthAtmosphere> createState() => _AuthAtmosphereState();
}

enum AuthAccent { coral, mint, ochre }

class _AuthAtmosphereState extends State<AuthAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (widget.accent) {
      AuthAccent.coral => colors.brandCoral,
      AuthAccent.mint => colors.brandMint,
      AuthAccent.ochre => colors.brandOchre,
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuthSkyPainter(
            t: _controller.value,
            canvas: colors.canvas,
            soft: colors.surfaceSoft,
            accent: accent,
            peach: colors.brandPeach,
            pink: colors.brandPink,
            mint: colors.brandMint,
            ink: colors.ink,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AuthSkyPainter extends CustomPainter {
  _AuthSkyPainter({
    required this.t,
    required this.canvas,
    required this.soft,
    required this.accent,
    required this.peach,
    required this.pink,
    required this.mint,
    required this.ink,
  });

  final double t;
  final Color canvas;
  final Color soft;
  final Color accent;
  final Color peach;
  final Color pink;
  final Color mint;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [this.canvas, soft, this.canvas],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect),
    );

    void blob(Offset c, double r, Color color) {
      canvas.drawCircle(c, r, Paint()..color = color);
    }

    final drift = math.sin(t * math.pi * 2);
    blob(
      Offset(size.width * 0.78 + drift * 12, size.height * 0.12),
      size.width * 0.42,
      accent.withValues(alpha: 0.22),
    );
    blob(
      Offset(size.width * 0.08, size.height * 0.22 + drift * 8),
      70,
      peach.withValues(alpha: 0.35),
    );
    blob(
      Offset(size.width * 0.92, size.height * 0.62),
      90,
      mint.withValues(alpha: 0.28),
    );
    blob(
      Offset(size.width * 0.2, size.height * 0.78),
      110,
      pink.withValues(alpha: 0.14),
    );

    final center = Offset(size.width * 0.86, size.height * 0.1);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final entry in [
      (48.0, 9.0, peach.withValues(alpha: 0.55)),
      (92.0, 2.2, accent.withValues(alpha: 0.45)),
      (138.0, 1.4, pink.withValues(alpha: 0.35)),
      (186.0, 2.8, mint.withValues(alpha: 0.3)),
    ]) {
      ringPaint
        ..strokeWidth = entry.$2
        ..color = entry.$3;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: entry.$1),
        t * math.pi * 2,
        math.pi * 1.35,
        false,
        ringPaint,
      );
    }

    final path = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * (0.82 + drift * 0.01),
        size.width,
        size.height * 0.9,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = ink.withValues(alpha: 0.03),
    );
  }

  @override
  bool shouldRepaint(covariant _AuthSkyPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// Shared layout for login / signup: brand hero + frosted form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.headline,
    required this.subcopy,
    required this.form,
    required this.footer,
    this.accent = AuthAccent.coral,
    this.heroMark = '01',
  });

  final String headline;
  final String subcopy;
  final Widget form;
  final Widget footer;
  final AuthAccent accent;
  final String heroMark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;
    final narrow = MediaQuery.sizeOf(context).width < 400;

    return Scaffold(
      body: AuthAtmosphere(
        accent: accent,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  spacing.lg,
                  spacing.lg,
                  spacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - spacing.lg - spacing.xl,
                    maxWidth: 440,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AuthEntrance(
                          delay: Duration.zero,
                          child: Row(
                            children: [
                              Text(
                                'ORBIT',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4.2,
                                  color: colors.brandCoral,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                heroMark,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color: colors.mutedSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.xxl),
                        _AuthEntrance(
                          delay: const Duration(milliseconds: 80),
                          child: Text(
                            'Orbit',
                            style: GoogleFonts.fraunces(
                              fontSize: narrow ? 64 : 78,
                              fontWeight: FontWeight.w500,
                              height: 0.9,
                              letterSpacing: -2.8,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        _AuthEntrance(
                          delay: const Duration(milliseconds: 140),
                          child: Text(
                            headline,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: narrow ? 28 : 34,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              letterSpacing: -0.8,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        _AuthEntrance(
                          delay: const Duration(milliseconds: 180),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              subcopy,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: colors.body,
                                    height: 1.45,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.xxl),
                        _AuthEntrance(
                          delay: const Duration(milliseconds: 240),
                          child: FrostedGlass(
                            borderRadius: radii.xlRadius,
                            blurSigma: 22,
                            tintOpacity: 0.62,
                            borderOpacity: 0.55,
                            padding: EdgeInsets.all(spacing.lg),
                            child: form,
                          ),
                        ),
                        SizedBox(height: spacing.lg),
                        _AuthEntrance(
                          delay: const Duration(milliseconds: 300),
                          child: footer,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.ink,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: colors.muted,
        ),
        filled: true,
        fillColor: colors.canvas.withValues(alpha: 0.72),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radii.lgRadius,
          borderSide: BorderSide(color: colors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radii.lgRadius,
          borderSide: BorderSide(color: colors.hairline.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radii.lgRadius,
          borderSide: BorderSide(color: colors.ink, width: 1.4),
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.hairline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: colors.mutedSoft,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.hairline)),
      ],
    );
  }
}

class _AuthEntrance extends StatefulWidget {
  const _AuthEntrance({
    required this.child,
    required this.delay,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_AuthEntrance> createState() => _AuthEntranceState();
}

class _AuthEntranceState extends State<_AuthEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
