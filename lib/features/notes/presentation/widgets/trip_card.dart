import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';
import 'package:orbit_notes/core/widgets/orbit_backdrop.dart';
import 'package:orbit_notes/features/notes/domain/entities/trip.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.index,
    required this.onTap,
    this.onDelete,
    this.isExample = false,
  });

  final Trip trip;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isExample;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final spacing = context.spacing;
    final accent = colors.accentAt(trip.accentIndex);
    final onAccent = colors.inkOn(accent);
    final dateFormat = DateFormat('MMM d');
    final hasCover =
        trip.coverPath != null && File(trip.coverPath!).existsSync();
    final tall = index.isEven;
    final height = tall ? 280.0 : 220.0;
    final tilt = index.isOdd ? -0.012 : 0.012;

    final card = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index * 70).clamp(0, 280)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - value)),
            child: Transform.rotate(
              angle: tilt * (1 - value * 0.4),
              child: child,
            ),
          ),
        );
      },
      child: Transform.rotate(
        angle: tilt,
        child: Padding(
          padding: EdgeInsets.only(
            left: index.isOdd ? spacing.md : 0,
            right: index.isEven ? spacing.md : 0,
          ),
          child: Material(
            color: accent,
            borderRadius: radii.xlRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              borderRadius: radii.xlRadius,
              child: SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasCover)
                      Image.file(
                        File(trip.coverPath!),
                        fit: BoxFit.cover,
                      )
                    else
                      CustomPaint(
                        painter: _CardOrbitPainter(
                          color: onAccent.withValues(alpha: 0.12),
                        ),
                      ),
                    if (hasCover)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    if (isExample)
                      Positioned(
                        top: spacing.md,
                        left: spacing.md,
                        child: FrostedGlass(
                          borderRadius: radii.smRadius,
                          tintOpacity: 0.72,
                          blurSigma: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'EXAMPLE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colors.ink,
                                  letterSpacing: 1.4,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: spacing.md,
                      right: spacing.md,
                      child: BigDayMark(
                        label: '${trip.dayCount}',
                        color: hasCover ? colors.onDark : onAccent,
                      ),
                    ),
                    Positioned(
                      left: spacing.md,
                      right: spacing.md,
                      bottom: spacing.md,
                      child: FrostedGlass(
                        borderRadius: radii.lgRadius,
                        tintOpacity: hasCover ? 0.48 : 0.28,
                        blurSigma: 20,
                        padding: EdgeInsets.all(spacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.destination.isEmpty
                                  ? 'Somewhere new'
                                  : trip.destination.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: hasCover
                                        ? colors.muted
                                        : onAccent.withValues(alpha: 0.8),
                                    letterSpacing: 1.6,
                                  ),
                            ),
                            SizedBox(height: spacing.xxs),
                            Text(
                              trip.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: hasCover ? colors.ink : onAccent,
                                    fontSize: tall ? 28 : 24,
                                    height: 1.1,
                                    letterSpacing: -0.8,
                                  ),
                            ),
                            SizedBox(height: spacing.xs),
                            Text(
                              '${dateFormat.format(trip.startDate)} → ${dateFormat.format(trip.endDate)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: hasCover
                                        ? colors.body
                                        : onAccent.withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isExample ? 'Remove example?' : 'Delete trip?'),
            content: Text(
              isExample
                  ? 'This sample won’t come back after you remove it.'
                  : '“${trip.title}” and its days, entries, and photos will be removed from this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (_) => onDelete!(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: spacing.lg),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.12),
          borderRadius: radii.xlRadius,
        ),
        child: Icon(Icons.delete_outline, color: colors.error),
      ),
      child: card,
    );
  }
}

class _CardOrbitPainter extends CustomPainter {
  _CardOrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    final c = Offset(size.width * 0.75, size.height * 0.3);
    canvas.drawCircle(c, 40, paint);
    canvas.drawCircle(c, 72, paint..strokeWidth = 1.5);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 110),
      math.pi * 0.2,
      math.pi * 1.1,
      false,
      paint..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _CardOrbitPainter oldDelegate) => false;
}
