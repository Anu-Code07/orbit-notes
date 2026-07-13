import 'package:flutter/material.dart';

/// Clay design-system color tokens for Orbit Notes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryActive,
    required this.primaryDisabled,
    required this.ink,
    required this.body,
    required this.bodyStrong,
    required this.muted,
    required this.mutedSoft,
    required this.hairline,
    required this.hairlineSoft,
    required this.canvas,
    required this.surfaceSoft,
    required this.surfaceCard,
    required this.surfaceStrong,
    required this.surfaceDark,
    required this.surfaceDarkElevated,
    required this.onPrimary,
    required this.onDark,
    required this.onDarkSoft,
    required this.brandPink,
    required this.brandTeal,
    required this.brandLavender,
    required this.brandPeach,
    required this.brandOchre,
    required this.brandMint,
    required this.brandCoral,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color primary;
  final Color primaryActive;
  final Color primaryDisabled;
  final Color ink;
  final Color body;
  final Color bodyStrong;
  final Color muted;
  final Color mutedSoft;
  final Color hairline;
  final Color hairlineSoft;
  final Color canvas;
  final Color surfaceSoft;
  final Color surfaceCard;
  final Color surfaceStrong;
  final Color surfaceDark;
  final Color surfaceDarkElevated;
  final Color onPrimary;
  final Color onDark;
  final Color onDarkSoft;
  final Color brandPink;
  final Color brandTeal;
  final Color brandLavender;
  final Color brandPeach;
  final Color brandOchre;
  final Color brandMint;
  final Color brandCoral;
  final Color success;
  final Color warning;
  final Color error;

  static const light = AppColors(
    primary: Color(0xFF0A0A0A),
    primaryActive: Color(0xFF1F1F1F),
    primaryDisabled: Color(0xFFE5E5E5),
    ink: Color(0xFF0A0A0A),
    body: Color(0xFF3A3A3A),
    bodyStrong: Color(0xFF1A1A1A),
    muted: Color(0xFF6A6A6A),
    mutedSoft: Color(0xFF9A9A9A),
    hairline: Color(0xFFE5E5E5),
    hairlineSoft: Color(0xFFF0F0F0),
    canvas: Color(0xFFFFFAF0),
    surfaceSoft: Color(0xFFFAF5E8),
    surfaceCard: Color(0xFFF5F0E0),
    surfaceStrong: Color(0xFFEBE6D6),
    surfaceDark: Color(0xFF0A1A1A),
    surfaceDarkElevated: Color(0xFF1A2A2A),
    onPrimary: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
    onDarkSoft: Color(0xFFA0A0A0),
    brandPink: Color(0xFFFF4D8B),
    brandTeal: Color(0xFF1A3A3A),
    brandLavender: Color(0xFFB8A4ED),
    brandPeach: Color(0xFFFFB084),
    brandOchre: Color(0xFFE8B94A),
    brandMint: Color(0xFFA4D4C5),
    brandCoral: Color(0xFFFF6B5A),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
  );

  /// Accent cycle for trip cards — never repeat adjacent colors.
  List<Color> get accentCycle => [
        brandPink,
        brandTeal,
        brandLavender,
        brandPeach,
        brandOchre,
        surfaceCard,
      ];

  Color accentAt(int index) => accentCycle[index % accentCycle.length];

  bool usesLightInkOn(Color surface) =>
      surface == brandPink || surface == brandTeal || surface == surfaceDark;

  Color inkOn(Color surface) =>
      usesLightInkOn(surface) ? onDark : ink;

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryActive,
    Color? primaryDisabled,
    Color? ink,
    Color? body,
    Color? bodyStrong,
    Color? muted,
    Color? mutedSoft,
    Color? hairline,
    Color? hairlineSoft,
    Color? canvas,
    Color? surfaceSoft,
    Color? surfaceCard,
    Color? surfaceStrong,
    Color? surfaceDark,
    Color? surfaceDarkElevated,
    Color? onPrimary,
    Color? onDark,
    Color? onDarkSoft,
    Color? brandPink,
    Color? brandTeal,
    Color? brandLavender,
    Color? brandPeach,
    Color? brandOchre,
    Color? brandMint,
    Color? brandCoral,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryActive: primaryActive ?? this.primaryActive,
      primaryDisabled: primaryDisabled ?? this.primaryDisabled,
      ink: ink ?? this.ink,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      muted: muted ?? this.muted,
      mutedSoft: mutedSoft ?? this.mutedSoft,
      hairline: hairline ?? this.hairline,
      hairlineSoft: hairlineSoft ?? this.hairlineSoft,
      canvas: canvas ?? this.canvas,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      surfaceDarkElevated: surfaceDarkElevated ?? this.surfaceDarkElevated,
      onPrimary: onPrimary ?? this.onPrimary,
      onDark: onDark ?? this.onDark,
      onDarkSoft: onDarkSoft ?? this.onDarkSoft,
      brandPink: brandPink ?? this.brandPink,
      brandTeal: brandTeal ?? this.brandTeal,
      brandLavender: brandLavender ?? this.brandLavender,
      brandPeach: brandPeach ?? this.brandPeach,
      brandOchre: brandOchre ?? this.brandOchre,
      brandMint: brandMint ?? this.brandMint,
      brandCoral: brandCoral ?? this.brandCoral,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      primaryDisabled: Color.lerp(primaryDisabled, other.primaryDisabled, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      body: Color.lerp(body, other.body, t)!,
      bodyStrong: Color.lerp(bodyStrong, other.bodyStrong, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedSoft: Color.lerp(mutedSoft, other.mutedSoft, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineSoft: Color.lerp(hairlineSoft, other.hairlineSoft, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      surfaceDarkElevated:
          Color.lerp(surfaceDarkElevated, other.surfaceDarkElevated, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onDark: Color.lerp(onDark, other.onDark, t)!,
      onDarkSoft: Color.lerp(onDarkSoft, other.onDarkSoft, t)!,
      brandPink: Color.lerp(brandPink, other.brandPink, t)!,
      brandTeal: Color.lerp(brandTeal, other.brandTeal, t)!,
      brandLavender: Color.lerp(brandLavender, other.brandLavender, t)!,
      brandPeach: Color.lerp(brandPeach, other.brandPeach, t)!,
      brandOchre: Color.lerp(brandOchre, other.brandOchre, t)!,
      brandMint: Color.lerp(brandMint, other.brandMint, t)!,
      brandCoral: Color.lerp(brandCoral, other.brandCoral, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
