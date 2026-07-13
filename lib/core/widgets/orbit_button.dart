import 'package:flutter/material.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';

enum OrbitButtonVariant { primary, secondary, onColor, frost, text }

class OrbitButton extends StatelessWidget {
  const OrbitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OrbitButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final OrbitButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final enabled = onPressed != null && !isLoading;

    if (variant == OrbitButtonVariant.frost) {
      return SizedBox(
        height: 44,
        width: expand ? double.infinity : null,
        child: FrostedGlass(
          borderRadius: radii.mdRadius,
          tintOpacity: 0.48,
          blurSigma: 20,
          onTap: enabled ? onPressed : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.ink,
                  ),
                )
              else ...[
                if (icon != null) ...[
                  Icon(icon, size: 18, color: colors.ink),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.ink,
                      ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Color background;
    Color foreground;
    BorderSide? border;

    switch (variant) {
      case OrbitButtonVariant.primary:
        background = enabled ? colors.primary : colors.primaryDisabled;
        foreground = enabled ? colors.onPrimary : colors.muted;
      case OrbitButtonVariant.secondary:
        background = colors.canvas;
        foreground = colors.ink;
        border = BorderSide(color: colors.hairline);
      case OrbitButtonVariant.onColor:
        background = colors.canvas;
        foreground = colors.ink;
      case OrbitButtonVariant.frost:
        background = colors.canvas;
        foreground = colors.ink;
      case OrbitButtonVariant.text:
        background = Colors.transparent;
        foreground = colors.ink;
    }

    return SizedBox(
      height: 44,
      width: expand ? double.infinity : null,
      child: Material(
        color: background,
        borderRadius: radii.mdRadius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radii.mdRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: radii.mdRadius,
              border: border == null ? null : Border.fromBorderSide(border),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: foreground,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
