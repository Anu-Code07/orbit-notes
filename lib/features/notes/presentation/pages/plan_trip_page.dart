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

class _PlanComposer extends StatefulWidget {
  const _PlanComposer({required this.form});

  final PlanTripFormState form;

  @override
  State<_PlanComposer> createState() => _PlanComposerState();
}

class _PlanComposerState extends State<_PlanComposer> {
  late final TextEditingController _vibeController;
  late final TextEditingController _mustController;

  static const _vibePresets = [
    ('Kyoto spring', 'Kyoto in cherry season — temples, tea, slow mornings'),
    ('Lisbon light', 'Lisbon hills & tiled streets — cafés, miradouros, tram rides'),
    ('Bali quiet', 'Quiet Bali — rice terraces, ocean evenings, yoga dawns'),
    ('NYC weekend', 'New York long weekend — museums, pizza, skyline walks'),
    ('Amalfi coast', 'Amalfi coast — cliffs, lemon groves, swimming coves'),
    ('Iceland road', 'Iceland road trip — waterfalls, hot springs, midnight sun'),
  ];

  static const _interests = [
    ('Epic views', Icons.terrain_outlined, Color(0xFFE8B94A)),
    ('Among trees', Icons.park_outlined, Color(0xFFA4D4C5)),
    ('Food trail', Icons.restaurant_outlined, Color(0xFFFF6B5A)),
    ('Quiet towns', Icons.cottage_outlined, Color(0xFF1A3A3A)),
    ('Night lights', Icons.nightlife_outlined, Color(0xFFB8A4ED)),
    ('Slow mornings', Icons.wb_twilight_outlined, Color(0xFFFFB084)),
    ('Museums', Icons.museum_outlined, Color(0xFF6B7C8A)),
    ('Beaches', Icons.beach_access_outlined, Color(0xFF5B9BD5)),
  ];

  static const _paces = [
    ('slow', 'Slow', 'Linger'),
    ('balanced', 'Balanced', 'Easy mix'),
    ('packed', 'Packed', 'See more'),
  ];

  static const _companions = [
    ('solo', 'Solo', Icons.person_outline),
    ('couple', 'Couple', Icons.favorite_border),
    ('friends', 'Friends', Icons.groups_outlined),
    ('family', 'Family', Icons.home_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _vibeController = TextEditingController(text: widget.form.vibe);
    _mustController = TextEditingController(text: widget.form.mustInclude);
  }

  @override
  void didUpdateWidget(covariant _PlanComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.form.vibe != widget.form.vibe &&
        _vibeController.text != widget.form.vibe) {
      _vibeController.text = widget.form.vibe;
    }
  }

  @override
  void dispose() {
    _vibeController.dispose();
    _mustController.dispose();
    super.dispose();
  }

  PlanTripFormState get form => widget.form;

  DateTime get _nextFriday => PlanTripFormState.smartStartDate();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        spacing.md,
        spacing.lg,
        spacing.section,
      ),
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
        SizedBox(height: spacing.sm),
        Text(
          'Smart defaults ready — tweak what you care about.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
        ),
        SizedBox(height: spacing.lg),
        _sectionLabel(context, 'LENGTH'),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            Expanded(
              child: _LengthChip(
                label: 'Weekend',
                hint: '3 days',
                selected: form.dayCount == 3,
                onTap: () => context.read<PlanTripBloc>().add(
                      PlanTripPresetApplied(
                        dayCount: 3,
                        startDate: _nextFriday,
                        pace: 'balanced',
                        interests: const {'Food trail', 'Slow mornings'},
                      ),
                    ),
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _LengthChip(
                label: 'Week',
                hint: '7 days',
                selected: form.dayCount == 7,
                onTap: () => context.read<PlanTripBloc>().add(
                      PlanTripPresetApplied(
                        dayCount: 7,
                        startDate: _nextFriday,
                        pace: 'slow',
                        interests: const {
                          'Among trees',
                          'Quiet towns',
                          'Food trail',
                        },
                      ),
                    ),
              ),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: _LengthChip(
                label: 'Custom',
                hint: '${form.dayCount} days',
                selected: form.dayCount != 3 && form.dayCount != 7,
                onTap: () => _pickDays(context, form.dayCount),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        _DayStepper(
          dayCount: form.dayCount,
          onChanged: (days) => context
              .read<PlanTripBloc>()
              .add(PlanTripDayCountChanged(days)),
        ),
        SizedBox(height: spacing.xl),
        Transform.rotate(
          angle: -0.02,
          child: _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(context, 'DESTINATION VIBE'),
                SizedBox(height: spacing.md),
                TextField(
                  controller: _vibeController,
                  onChanged: (v) => context
                      .read<PlanTripBloc>()
                      .add(PlanTripVibeChanged(v)),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Where should the story go?',
                    hintStyle: TextStyle(color: colors.mutedSoft),
                    filled: true,
                    fillColor: colors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(spacing.md),
                  ),
                ),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: _vibePresets.map((preset) {
                    final selected = form.vibe == preset.$2;
                    return _PillChip(
                      label: preset.$1,
                      selected: selected,
                      onTap: () {
                        _vibeController.text = preset.$2;
                        context
                            .read<PlanTripBloc>()
                            .add(PlanTripVibeChanged(preset.$2));
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        Transform.rotate(
          angle: 0.018,
          child: _SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(context, 'POINTS OF INTEREST'),
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: _interests.map((item) {
                    final selected = form.interests.contains(item.$1);
                    return _InterestChip(
                      label: item.$1,
                      icon: item.$2,
                      accent: item.$3,
                      selected: selected,
                      onTap: () => context
                          .read<PlanTripBloc>()
                          .add(PlanTripInterestToggled(item.$1)),
                    );
                  }).toList(),
                ),
                SizedBox(height: spacing.lg),
                Divider(color: colors.hairline),
                SizedBox(height: spacing.lg),
                _sectionLabel(context, 'PACE'),
                SizedBox(height: spacing.sm),
                Row(
                  children: _paces.map((pace) {
                    final selected = form.pace == pace.$1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: pace.$1 == _paces.last.$1 ? 0 : spacing.sm,
                        ),
                        child: _SegmentCard(
                          title: pace.$2,
                          subtitle: pace.$3,
                          selected: selected,
                          onTap: () => context
                              .read<PlanTripBloc>()
                              .add(PlanTripPaceChanged(pace.$1)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: spacing.lg),
                _sectionLabel(context, 'WITH'),
                SizedBox(height: spacing.sm),
                Row(
                  children: _companions.map((c) {
                    final selected = form.companions == c.$1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: c.$1 == _companions.last.$1 ? 0 : spacing.sm,
                        ),
                        child: _IconSegment(
                          icon: c.$3,
                          label: c.$2,
                          selected: selected,
                          onTap: () => context
                              .read<PlanTripBloc>()
                              .add(PlanTripCompanionsChanged(c.$1)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: spacing.lg),
                Divider(color: colors.hairline),
                SizedBox(height: spacing.lg),
                _sectionLabel(context, 'STARTS'),
                SizedBox(height: spacing.md),
                _MetricTile(
                  icon: Icons.calendar_today_outlined,
                  value: DateFormat('EEE d MMM').format(form.startDate),
                  label: 'TAP TO CHANGE',
                  onTap: () => _pickStart(context, form.startDate),
                ),
                SizedBox(height: spacing.md),
                TextField(
                  controller: _mustController,
                  onChanged: (v) => context
                      .read<PlanTripBloc>()
                      .add(PlanTripMustIncludeChanged(v)),
                  decoration: InputDecoration(
                    hintText: 'Must include (optional)',
                    filled: true,
                    fillColor: colors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
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
          form.vibe.isEmpty
              ? 'Pick a vibe preset or type your own destination dream.'
              : '${form.dayCount} days · ${form.pace} · ${form.companions}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      ':: $text',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            color: context.colors.muted,
          ),
    );
  }

  Future<void> _pickDays(BuildContext context, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.colors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Custom days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: List.generate(13, (i) {
                      final days = i + 2;
                      return ListTile(
                        title: Text('$days days'),
                        trailing:
                            days == current ? const Icon(Icons.check) : null,
                        onTap: () => Navigator.pop(context, days),
                      );
                    }),
                  ),
                ),
              ],
            ),
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && context.mounted) {
      context.read<PlanTripBloc>().add(PlanTripStartDateChanged(picked));
    }
  }
}

class _LengthChip extends StatelessWidget {
  const _LengthChip({
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.brandCoral.withValues(alpha: 0.16) : colors.canvas,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.brandCoral : colors.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.fraunces(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

class _DayStepper extends StatelessWidget {
  const _DayStepper({
    required this.dayCount,
    required this.onChanged,
  });

  final int dayCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.hairline),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Days',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          _StepperButton(
            icon: Icons.remove,
            onTap: dayCount <= 2 ? null : () => onChanged(dayCount - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$dayCount',
              style: GoogleFonts.fraunces(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: dayCount >= 14 ? null : () => onChanged(dayCount + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? colors.mutedSoft : colors.ink,
          ),
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.ink : colors.surfaceSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.onPrimary : colors.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : colors.surfaceSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : colors.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  const _SegmentCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.ink : colors.surfaceSoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? colors.onPrimary : colors.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? colors.onPrimary.withValues(alpha: 0.7)
                          : colors.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconSegment extends StatelessWidget {
  const _IconSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.brandCoral.withValues(alpha: 0.15) : colors.surfaceSoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? colors.brandCoral : colors.hairline,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? colors.brandCoral : colors.muted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
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
  });

  final PlannedTripDay day;
  final Color accent;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;

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
                  _PlaceHeroImage(accent: accent),
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
  const _PlaceHeroImage({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 148,
      child: ColoredBox(
        color: accent.withValues(alpha: 0.16),
        child: Center(
          child: Icon(
            Icons.landscape_outlined,
            color: colors.mutedSoft,
            size: 36,
          ),
        ),
      ),
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
