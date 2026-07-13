import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colors = AppColors.light;
    const spacing = AppSpacing.defaults;
    const radii = AppRadii.defaults;

    final base = GoogleFonts.interTextTheme();

    TextStyle display({
      required double size,
      required double height,
      required double tracking,
    }) {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: height,
        letterSpacing: tracking,
        color: colors.ink,
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.canvas,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.brandTeal,
        onSecondary: colors.onDark,
        surface: colors.canvas,
        onSurface: colors.ink,
        error: colors.error,
        onError: colors.onPrimary,
        outline: colors.hairline,
      ),
      textTheme: base.copyWith(
        displayLarge: display(size: 72, height: 1, tracking: -2.5),
        displayMedium: display(size: 56, height: 1.05, tracking: -2),
        displaySmall: display(size: 40, height: 1.1, tracking: -1),
        headlineMedium: display(size: 32, height: 1.15, tracking: -0.5),
        titleLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.3,
          color: colors.ink,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: colors.ink,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: colors.ink,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: colors.body,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: colors.body,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1,
          color: colors.ink,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: colors.ink,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: 1.5,
          color: colors.muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.canvas,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.md),
          borderSide: BorderSide(color: colors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.md),
          borderSide: BorderSide(color: colors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.md),
          borderSide: BorderSide(color: colors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radii.md),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: GoogleFonts.inter(color: colors.mutedSoft, fontSize: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.hairline, thickness: 1),
      extensions: const [colors, spacing, radii],
    );
  }
}
