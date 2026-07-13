import 'dart:io';

import 'package:flutter/material.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/features/notes/domain/entities/photo.dart';

class PhotoGalleryStrip extends StatelessWidget {
  const PhotoGalleryStrip({super.key, required this.photos});

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final spacing = context.spacing;

    if (photos.isEmpty) {
      return Container(
        height: 140,
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

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
        itemBuilder: (context, index) {
          final photo = photos[index];
          final rotate = ((index % 3) - 1) * 0.04;
          final tall = index.isEven;

          return Transform.rotate(
            angle: rotate,
            child: Align(
              alignment: tall ? Alignment.topCenter : Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radii.xl),
                  topRight: Radius.circular(radii.md),
                  bottomLeft: Radius.circular(radii.md),
                  bottomRight: Radius.circular(radii.xl),
                ),
                child: SizedBox(
                  width: tall ? 128 : 112,
                  height: tall ? 168 : 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.localPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: colors.surfaceStrong,
                          child: Icon(Icons.broken_image, color: colors.muted),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.canvas.withValues(alpha: 0.85),
                            borderRadius: radii.pillRadius,
                          ),
                          child: Text(
                            '${index + 1}'.padLeft(2, '0'),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
