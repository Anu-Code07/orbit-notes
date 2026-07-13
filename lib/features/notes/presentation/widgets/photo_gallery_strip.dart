import 'dart:io';

import 'package:flutter/material.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';

/// Scrapbook-style overlapping photo collage for trip moments.
class PhotoGalleryStrip extends StatelessWidget {
  const PhotoGalleryStrip({super.key, required this.photos});

  final List<Photo> photos;

  static const _maxVisible = 7;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final spacing = context.spacing;

    if (photos.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: radii.xlRadius,
          border: Border.all(color: colors.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, color: colors.mutedSoft, size: 28),
            SizedBox(height: spacing.xs),
            Text(
              'Moments will land here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.muted,
                  ),
            ),
          ],
        ),
      );
    }

    final visible = photos.take(_maxVisible).toList();
    final overflow = photos.length - visible.length;

    return SizedBox(
      height: 210,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < visible.length; i++)
                _ScatteredFrame(
                  photo: visible[i],
                  index: i,
                  total: visible.length,
                  width: constraints.maxWidth,
                  onTap: () => _openPreview(context, photos, i),
                ),
              if (overflow > 0)
                Positioned(
                  right: 8,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.ink,
                      borderRadius: radii.pillRadius,
                    ),
                    child: Text(
                      '+$overflow more',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onPrimary,
                          ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openPreview(BuildContext context, List<Photo> all, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.file(
                  File(all[index].localPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: context.colors.surfaceStrong,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScatteredFrame extends StatelessWidget {
  const _ScatteredFrame({
    required this.photo,
    required this.index,
    required this.total,
    required this.width,
    required this.onTap,
  });

  final Photo photo;
  final int index;
  final int total;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final angles = [-0.14, 0.08, -0.06, 0.12, -0.1, 0.05, 0.16];
    final sizes = [118.0, 132.0, 110.0, 140.0, 124.0, 116.0, 128.0];
    final angle = angles[index % angles.length];
    final size = sizes[index % sizes.length];

    final step = total <= 1 ? 0.0 : (width - size - 24) / (total - 1);
    final left = 8 + step * index;
    final top = 18.0 + (index.isEven ? 0 : 28) + (index % 3) * 4;

    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 420 + index * 70),
        curve: Curves.easeOutBack,
        builder: (context, t, child) {
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: angle * t,
              child: Transform.scale(scale: 0.86 + 0.14 * t, child: child),
            ),
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size * 1.2,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
            decoration: BoxDecoration(
              color: colors.canvas,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: Offset(2, 8 + index.toDouble()),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(photo.localPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: colors.surfaceStrong,
                  child: Icon(Icons.broken_image, color: colors.muted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
