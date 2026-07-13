import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';

/// Soft frosted-glass surface (blur + translucent cream tint).
class FrostedGlass extends StatelessWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma = 18,
    this.tintOpacity = 0.55,
    this.borderOpacity = 0.45,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final double tintOpacity;
  final double borderOpacity;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? context.radii.mdRadius;

    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.canvas.withValues(alpha: (tintOpacity + 0.12).clamp(0, 1)),
                colors.canvas.withValues(alpha: (tintOpacity - 0.08).clamp(0, 1)),
              ],
            ),
          ),
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}

/// Circular frosted control (back / icon buttons over media).
class FrostedIconButton extends StatelessWidget {
  const FrostedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FrostedGlass(
      borderRadius: BorderRadius.circular(size / 2),
      tintOpacity: 0.42,
      blurSigma: 16,
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: 20, color: colors.ink),
      ),
    );
  }
}
