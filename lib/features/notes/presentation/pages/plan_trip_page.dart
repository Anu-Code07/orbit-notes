import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/orbit_backdrop.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/notes/data/datasources/place_image_service.dart';
import 'package:orbit_notes/features/notes/domain/entities/planned_trip.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/plan_trip/plan_trip_bloc.dart';

class PlanTripPage extends StatelessWidget {
  const PlanTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlanTripBloc>(),
      child: const _PlanTripView(),
    );
  }
}

class _PlanTripView extends StatelessWidget {
  const _PlanTripView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return BlocConsumer<PlanTripBloc, PlanTripState>(
      listener: (context, state) {
        if (state is PlanTripCreated) {
          context.go('/trips/${state.trip.id}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.canvas,
          body: OrbitBackdrop(
            intensity: 1.15,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.sm,
                      spacing.sm,
                      spacing.lg,
                      0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close),
                        ),
                        const Spacer(),
                        Text(
                          'PLAN',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.brandCoral,
                                letterSpacing: 2.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _bodyFor(context, state, spacing, colors)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bodyFor(
    BuildContext context,
    PlanTripState state,
    AppSpacing spacing,
    AppColors colors,
  ) {
    if (state is PlanTripGenerating) {
      return const _PlanningLoader();
    }
    if (state is PlanTripPreview || state is PlanTripCreating) {
      final preview = state is PlanTripPreview
          ? state
          : PlanTripPreview(
              form: (state as PlanTripCreating).form,
              plan: state.plan,
            );
      return _PlanTimeline(
        plan: preview.plan,
        form: preview.form,
        error: preview.error,
        creating: state is PlanTripCreating,
      );
    }
    final form = state is PlanTripFormState
        ? state
        : PlanTripFormState();
    return _PlanComposer(form: form);
  }
}

class _PlanComposer extends StatelessWidget {
  const _PlanComposer({required this.form});

  final PlanTripFormState form;

  static const interests = [
    ('Epic views', Icons.terrain_outlined, Color(0xFFE8B94A)),
    ('Among trees', Icons.park_outlined, Color(0xFFA4D4C5)),
    ('Food trail', Icons.restaurant_outlined, Color(0xFFFF6B5A)),
    ('Quiet towns', Icons.cottage_outlined, Color(0xFF1A3A3A)),
    ('Night lights', Icons.nightlife_outlined, Color(0xFFB8A4ED)),
    ('Slow mornings', Icons.wb_twilight_outlined, Color(0xFFFFB084)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ListView(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.section),
      children: [
        Text(
          'Plan your\nPerfect Trip',
          style: GoogleFonts.fraunces(
            fontSize: 40,
            height: 1.05,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: colors.ink,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: spacing.xl),
        Transform.rotate(
          angle: -0.03,
          child: _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Where should the story go?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SizedBox(height: spacing.md),
                TextField(
                  onChanged: (v) => context
                      .read<PlanTripBloc>()
                      .add(PlanTripVibeChanged(v)),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Kyoto spring · temples · slow cafés',
                    suffixIcon: Icon(
                      Icons.search,
                      color: colors.mutedSoft,
                    ),
                    filled: true,
                    fillColor: colors.surfaceSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        Transform.rotate(
          angle: 0.025,
          child: _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ':: POINTS OF INTEREST',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: colors.muted,
                      ),
                ),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: interests.map((item) {
                    final selected = form.interests.contains(item.$1);
                    return FilterChip(
                      selected: selected,
                      showCheckmark: false,
                      avatar: Icon(item.$2, size: 16, color: item.$3),
                      label: Text(item.$1.toUpperCase()),
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 0.6,
                            color: colors.ink,
                          ),
                      selectedColor: colors.surfaceStrong,
                      backgroundColor: colors.surfaceSoft,
                      side: BorderSide(
                        color: selected ? colors.ink : colors.hairline,
                      ),
                      onSelected: (_) => context
                          .read<PlanTripBloc>()
                          .add(PlanTripInterestToggled(item.$1)),
                    );
                  }).toList(),
                ),
                SizedBox(height: spacing.lg),
                Divider(color: colors.hairline),
                SizedBox(height: spacing.lg),
                Text(
                  ':: TRIP SHAPE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        color: colors.muted,
                      ),
                ),
                SizedBox(height: spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.umbrella_outlined,
                        value: '${form.dayCount}',
                        label: 'VACATION DAYS',
                        onTap: () => _pickDays(context, form.dayCount),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: _MetricTile(
                        icon: Icons.calendar_today_outlined,
                        value: DateFormat('d MMM').format(form.startDate),
                        label: 'STARTS',
                        onTap: () => _pickStart(context, form.startDate),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                TextField(
                  onChanged: (v) => context
                      .read<PlanTripBloc>()
                      .add(PlanTripMustIncludeChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Must include (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (form.error != null) ...[
          SizedBox(height: spacing.md),
          Text(
            form.error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                ),
          ),
        ],
        SizedBox(height: spacing.xl),
        OrbitButton(
          label: 'Weave this trip',
          icon: Icons.auto_awesome,
          onPressed: () => context
              .read<PlanTripBloc>()
              .add(const PlanTripGenerateRequested()),
        ),
        SizedBox(height: spacing.sm),
        Text(
          'AI drafts days you can edit into your journal.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
        ),
      ],
    );
  }

  Future<void> _pickDays(BuildContext context, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.colors.canvas,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: List.generate(10, (i) {
              final days = i + 2;
              return ListTile(
                title: Text('$days days'),
                trailing: days == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, days),
              );
            }),
          ),
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<PlanTripBloc>().add(PlanTripDayCountChanged(picked));
    }
  }

  Future<void> _pickStart(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && context.mounted) {
      context.read<PlanTripBloc>().add(PlanTripStartDateChanged(picked));
    }
  }
}

class _PlanTimeline extends StatelessWidget {
  const _PlanTimeline({
    required this.plan,
    required this.form,
    required this.creating,
    this.error,
  });

  final PlannedTrip plan;
  final PlanTripFormState form;
  final bool creating;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final accents = [
      colors.brandCoral,
      colors.brandPeach,
      colors.brandMint,
      colors.brandOchre,
      colors.brandPink,
      colors.brandTeal,
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.md,
              spacing.lg,
              spacing.lg,
            ),
            children: [
              Text(
                'Your ${plan.destination} trip plan',
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                  height: 1.15,
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 16, color: colors.muted),
                  SizedBox(width: spacing.xs),
                  Text(
                    DateFormat('d MMM yyyy').format(form.startDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.muted,
                        ),
                  ),
                ],
              ),
              if (plan.summary.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Text(
                  plan.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.body,
                        height: 1.4,
                      ),
                ),
              ],
              SizedBox(height: spacing.xl),
              ...plan.days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final accent = accents[index % accents.length];
                final isLast = index == plan.days.length - 1;
                return _TimelineDayCard(
                  day: day,
                  accent: accent,
                  showLine: !isLast,
                  destination: plan.destination,
                );
              }),
              if (error != null) ...[
                SizedBox(height: spacing.md),
                Text(
                  error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.error,
                      ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OrbitButton(
                  label: 'Edit vibe',
                  variant: OrbitButtonVariant.secondary,
                  onPressed: creating
                      ? null
                      : () => context
                          .read<PlanTripBloc>()
                          .add(const PlanTripResetRequested()),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                flex: 2,
                child: OrbitButton(
                  label: 'Create journal',
                  isLoading: creating,
                  onPressed: creating
                      ? null
                      : () => context
                          .read<PlanTripBloc>()
                          .add(const PlanTripCreateJournalRequested()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineDayCard extends StatelessWidget {
  const _TimelineDayCard({
    required this.day,
    required this.accent,
    required this.showLine,
    required this.destination,
  });

  final PlannedTripDay day;
  final Color accent;
  final bool showLine;
  final String destination;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;
    final imageQuery = (day.placeHint?.trim().isNotEmpty ?? false)
        ? day.placeHint!.trim()
        : '$destination ${day.title}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.canvas, width: 2),
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: CustomPaint(
                      painter: _DashedLinePainter(color: colors.hairline),
                      child: const SizedBox(width: 2),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: spacing.md),
              decoration: BoxDecoration(
                color: colors.canvas,
                borderRadius: BorderRadius.circular(radii.xl),
                boxShadow: [
                  BoxShadow(
                    color: colors.ink.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlaceHeroImage(query: imageQuery, accent: accent),
                  Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.place_outlined,
                            color: accent,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAY ${day.dayIndex}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: accent,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              SizedBox(height: spacing.xs),
                              Text(
                                day.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (day.placeHint != null) ...[
                                SizedBox(height: spacing.xs),
                                Text(
                                  day.placeHint!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: colors.muted),
                                ),
                              ],
                              SizedBox(height: spacing.sm),
                              Text(
                                day.entryPrompt,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colors.body,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceHeroImage extends StatelessWidget {
  const _PlaceHeroImage({required this.query, required this.accent});

  final String query;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FutureBuilder<String?>(
      future: getIt<PlaceImageService>().imageUrlFor(query),
      builder: (context, snapshot) {
        final url = snapshot.data;
        return SizedBox(
          height: 148,
          child: url == null
              ? ColoredBox(
                  color: accent.withValues(alpha: 0.16),
                  child: Center(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Icon(Icons.landscape_outlined,
                            color: colors.mutedSoft, size: 36),
                  ),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: accent.withValues(alpha: 0.16),
                    child: Icon(Icons.landscape_outlined,
                        color: colors.mutedSoft, size: 36),
                  ),
                ),
        );
      },
    );
  }
}

class _PlanningLoader extends StatefulWidget {
  const _PlanningLoader();

  @override
  State<_PlanningLoader> createState() => _PlanningLoaderState();
}

class _PlanningLoaderState extends State<_PlanningLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _OrbitLoaderPainter(
                    progress: _controller.value,
                    ring: colors.brandCoral,
                    ink: colors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Charting your days…',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return Material(
      color: colors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.canvas,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: colors.ink),
              ),
              SizedBox(height: spacing.sm),
              Text(
                value,
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.1,
                      color: colors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _OrbitLoaderPainter extends CustomPainter {
  _OrbitLoaderPainter({
    required this.progress,
    required this.ring,
    required this.ink,
  });

  final double progress;
  final Color ring;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    canvas.drawCircle(center, radius * 0.35, Paint()..color = ink);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);
    canvas.scale(1.2, 0.55);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = ring,
    );
    canvas.drawCircle(Offset(radius, 0), 5, Paint()..color = ring);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
