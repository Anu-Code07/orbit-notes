import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/entities/entry.dart';

class DayTimelineCard extends StatelessWidget {
  const DayTimelineCard({
    super.key,
    required this.day,
    required this.entries,
    required this.accent,
    required this.index,
    required this.onAddEntry,
    required this.onOpenEntry,
    this.isLast = false,
  });

  final Day day;
  final List<Entry> entries;
  final Color accent;
  final int index;
  final VoidCallback onAddEntry;
  final void Function(Entry entry) onOpenEntry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.radii;
    final spacing = context.spacing;
    final onAccent = colors.inkOn(accent);
    final dateLabel = DateFormat('EEE · MMM d').format(day.date);
    final dayNum = (index + 1).toString().padLeft(2, '0');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 70).clamp(0, 280)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(24 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.canvas, width: 3),
                    ),
                    child: Text(
                      dayNum,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: onAccent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: EdgeInsets.symmetric(vertical: spacing.xs),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent,
                              accent.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: spacing.lg),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(radii.sm),
                    topRight: Radius.circular(radii.xl),
                    bottomLeft: Radius.circular(radii.xl),
                    bottomRight: Radius.circular(radii.xl),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: onAccent.withValues(alpha: 0.75),
                            letterSpacing: 1.4,
                          ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      day.title?.isNotEmpty == true
                          ? day.title!
                          : 'Day ${index + 1}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: onAccent,
                            fontSize: 22,
                            letterSpacing: -0.4,
                          ),
                    ),
                    if (day.note != null && day.note!.isNotEmpty) ...[
                      SizedBox(height: spacing.xs),
                      Text(
                        day.note!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: onAccent.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                    if (entries.isNotEmpty) ...[
                      SizedBox(height: spacing.md),
                      ...entries.map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(bottom: spacing.sm),
                          child: FrostedGlass(
                            borderRadius: radii.lgRadius,
                            tintOpacity: 0.52,
                            blurSigma: 14,
                            onTap: () => onOpenEntry(entry),
                            padding: EdgeInsets.all(spacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.placeName != null) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place_outlined,
                                        size: 14,
                                        color: colors.brandCoral,
                                      ),
                                      SizedBox(width: spacing.xxs),
                                      Text(
                                        entry.placeName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(color: colors.ink),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: spacing.xxs),
                                ],
                                Text(
                                  entry.body,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onAddEntry,
                        icon: Icon(Icons.edit_note, color: onAccent, size: 18),
                        label: Text(
                          'Write this day',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: onAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
