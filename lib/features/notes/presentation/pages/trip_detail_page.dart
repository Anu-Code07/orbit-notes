import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/frosted_glass.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/notes/domain/entities/day.dart';
import 'package:orbit_notes/features/notes/domain/usecases/journal_usecases.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/trip_detail/trip_detail_bloc.dart';
import 'package:orbit_notes/features/notes/presentation/widgets/day_timeline_card.dart';
import 'package:orbit_notes/features/notes/presentation/widgets/photo_gallery_strip.dart';
import 'package:orbit_notes/features/notes/presentation/widgets/trip_map_view.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TripDetailBloc>()..add(LoadTripDetail(tripId)),
      child: const _TripDetailView(),
    );
  }
}

class _TripDetailView extends StatefulWidget {
  const _TripDetailView();

  @override
  State<_TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<_TripDetailView> {
  final _scrollController = ScrollController();
  int? _pendingDayCount;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickCover(BuildContext context) async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null || !context.mounted) return;
      final path = await getIt<PersistImage>()(file.path);
      if (!context.mounted) return;
      context.read<TripDetailBloc>().add(UpdateTripCover(path));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Photo access was denied. Enable it in Settings to add a cover.',
          ),
        ),
      );
    }
  }

  void _addDay(BuildContext context, TripDetailSuccess state) {
    final lastDate = state.days.isEmpty
        ? DateTime(
            state.trip.startDate.year,
            state.trip.startDate.month,
            state.trip.startDate.day,
          )
        : DateTime(
            state.days.last.date.year,
            state.days.last.date.month,
            state.days.last.date.day + 1,
          );
    final dayNumber = state.days.length + 1;
    _pendingDayCount = dayNumber;
    context.read<TripDetailBloc>().add(
          AddDayToTrip(
            Day(
              id: const Uuid().v4(),
              tripId: state.trip.id,
              date: lastDate,
              title: 'Day $dayNumber',
              createdAt: DateTime.now(),
            ),
          ),
        );
  }

  void _onDetailState(BuildContext context, TripDetailState state) {
    if (state is! TripDetailSuccess || _pendingDayCount == null) return;
    if (state.days.length < _pendingDayCount!) return;

    final added = _pendingDayCount!;
    _pendingDayCount = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Day $added added to the timeline')),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;

    return Scaffold(
      body: BlocConsumer<TripDetailBloc, TripDetailState>(
        listener: _onDetailState,
        builder: (context, state) {
          if (state is TripDetailLoading || state is TripDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TripDetailError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.failure.message),
                    SizedBox(height: spacing.md),
                    OrbitButton(
                      label: 'Back',
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! TripDetailSuccess) {
            return const SizedBox.shrink();
          }

          final trip = state.trip;
          final dateFmt = DateFormat('MMM d');
          final coverExists =
              trip.coverPath != null && File(trip.coverPath!).existsSync();

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.sizeOf(context).height * 0.55,
                pinned: true,
                backgroundColor: colors.canvas,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FrostedIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverExists)
                        Image.file(
                          File(trip.coverPath!),
                          fit: BoxFit.cover,
                        )
                      else
                        ColoredBox(color: colors.accentAt(trip.accentIndex)),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: spacing.lg,
                        right: spacing.lg,
                        bottom: spacing.xl,
                        child: FrostedGlass(
                          borderRadius: radii.xlRadius,
                          tintOpacity: 0.28,
                          blurSigma: 22,
                          padding: EdgeInsets.all(spacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: colors.ink,
                                      fontSize:
                                          MediaQuery.sizeOf(context).width < 400
                                              ? 32
                                              : 40,
                                    ),
                              ),
                              SizedBox(height: spacing.xs),
                              Text(
                                [
                                  if (trip.destination.isNotEmpty)
                                    trip.destination,
                                  '${dateFmt.format(trip.startDate)} – ${dateFmt.format(trip.endDate)}',
                                ].join(' · '),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: colors.bodyStrong,
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
              // Actions live outside FlexibleSpaceBar — taps there are swallowed.
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.lg,
                    spacing.lg,
                    spacing.lg,
                    spacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OrbitButton(
                          label: 'Add day',
                          icon: Icons.add,
                          onPressed: () => _addDay(context, state),
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: OrbitButton(
                          label: coverExists ? 'Change cover' : 'Add cover',
                          variant: OrbitButtonVariant.secondary,
                          icon: Icons.photo_outlined,
                          onPressed: () => _pickCover(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.lg,
                    spacing.md,
                    spacing.lg,
                    spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAP',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        'Where the days landed',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.sm),
                      TripMapView(pins: state.pins),
                      SizedBox(height: spacing.xxl),
                      Text(
                        'GALLERY',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        'Scattered frames',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.sm),
                      PhotoGalleryStrip(photos: state.photos),
                      SizedBox(height: spacing.xxl),
                      Text(
                        'TIMELINE',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        'Day by day',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: spacing.sm),
                      if (state.days.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(spacing.lg),
                          decoration: BoxDecoration(
                            color: colors.surfaceCard,
                            borderRadius: radii.xlRadius,
                          ),
                          child: Text(
                            'Add a day to start journaling.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: colors.muted),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  0,
                  spacing.lg,
                  spacing.section,
                ),
                sliver: SliverList.separated(
                  itemCount: state.days.length,
                  separatorBuilder: (_, __) => SizedBox(height: spacing.md),
                  itemBuilder: (context, index) {
                    final day = state.days[index];
                    final entries = state.entriesByDay[day.id] ?? [];
                    return DayTimelineCard(
                      day: day,
                      entries: entries,
                      accent: colors.accentAt(
                        (trip.accentIndex + index) % 6,
                      ),
                      index: index,
                      isLast: index == state.days.length - 1,
                      onAddEntry: () async {
                        await context.push(
                          '/trips/${trip.id}/days/${day.id}/entries/new',
                        );
                        if (context.mounted) {
                          context
                              .read<TripDetailBloc>()
                              .add(const RefreshTripDetail());
                        }
                      },
                      onOpenEntry: (entry) async {
                        await context.push(
                          '/trips/${trip.id}/days/${day.id}/entries/${entry.id}',
                        );
                        if (context.mounted) {
                          context
                              .read<TripDetailBloc>()
                              .add(const RefreshTripDetail());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
