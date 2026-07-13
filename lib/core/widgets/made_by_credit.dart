import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';

/// Quiet maker credit — always softer than the Orbit brand.
class MadeByCredit extends StatelessWidget {
  const MadeByCredit({
    super.key,
    this.align = TextAlign.start,
  });

  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      'by Anurag',
      textAlign: align,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        color: colors.mutedSoft.withValues(alpha: 0.72),
      ),
    );
  }
}
