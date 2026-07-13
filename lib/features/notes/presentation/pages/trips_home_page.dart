import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_radii.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/orbit_backdrop.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:orbit_notes/features/notes/presentation/bloc/trips/trips_bloc.dart';
import 'package:orbit_notes/features/notes/presentation/widgets/trip_card.dart';

class TripsHomePage extends StatelessWidget {
  const TripsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TripsBloc>()..add(const LoadTrips()),
      child: const _TripsHomeView(),
    );
  }
}

class _TripsHomeView extends StatefulWidget {
  const _TripsHomeView();

  @override
  State<_TripsHomeView> createState() => _TripsHomeViewState();
}

class _TripsHomeViewState extends State<_TripsHomeView> {
  final _newTripKey = GlobalKey();
  final _exampleTripKey = GlobalKey();
  final _accountKey = GlobalKey();
  bool _tourScheduled = false;

  void _maybeStartTour(TripsState state) {
    if (_tourScheduled) return;
    final prefs = getIt<AppPrefs>();
    if (prefs.hasSeenHomeTour) return;
    if (state is! TripsSuccess && state is! TripsEmpty) return;

    _tourScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keys = <GlobalKey>[
        _newTripKey,
        if (state is TripsSuccess) _exampleTripKey,
        _accountKey,
      ];
      ShowcaseView.get().startShowCase(keys);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final narrow = MediaQuery.sizeOf(context).width < 400;

    return Scaffold(
      body: OrbitBackdrop(
        child: SafeArea(
          child: BlocConsumer<TripsBloc, TripsState>(
            listener: (context, state) => _maybeStartTour(state),
            builder: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _maybeStartTour(state);
              });
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.lg,
                        spacing.xxl,
                        spacing.lg,
                        spacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORBIT',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: colors.brandCoral,
                                  letterSpacing: 3,
                                ),
                          ),
                          SizedBox(height: spacing.sm),
                          Text(
                            'Orbit',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: narrow ? 56 : 72,
                                  height: 0.92,
                                  letterSpacing: -2.5,
                                ),
                          ),
                          SizedBox(height: spacing.md),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Text(
                              'Collect days. Pin places. Keep the trip offline.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: colors.body,
                                    height: 1.45,
                                  ),
                            ),
                          ),
                          const _SignedInAsLine(),
                          SizedBox(height: spacing.xl),
                          Row(
                            children: [
                              Showcase(
                                key: _newTripKey,
                                title: 'Start a real trip',
                                description:
                                    'Tap New trip to create your own journal. '
                                    'Orbit organizes everything as Trip → Day → Entry.',
                                titleTextStyle: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: colors.ink,
                                ),
                                descTextStyle: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: colors.body,
                                ),
                                tooltipBackgroundColor: colors.canvas,
                                child: OrbitButton(
                                  label: 'New trip',
                                  icon: Icons.add,
                                  onPressed: () async {
                                    final created = await context
                                        .push<bool>('/trips/new');
                                    if (created == true && context.mounted) {
                                      context
                                          .read<TripsBloc>()
                                          .add(const RefreshTrips());
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: spacing.sm),
                              OrbitButton(
                                label: 'Plan',
                                variant: OrbitButtonVariant.secondary,
                                icon: Icons.auto_awesome,
                                onPressed: () async {
                                  await context.push('/trips/plan');
                                  if (context.mounted) {
                                    context
                                        .read<TripsBloc>()
                                        .add(const RefreshTrips());
                                  }
                                },
                              ),
                              SizedBox(width: spacing.sm),
                              Showcase(
                                key: _accountKey,
                                title: 'Sync when ready',
                                description:
                                    'Sign in anytime to sync trips to the cloud. '
                                    'You can keep journaling offline too.',
                                titleTextStyle: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: colors.ink,
                                ),
                                descTextStyle: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: colors.body,
                                ),
                                tooltipBackgroundColor: colors.canvas,
                                child: const _AccountActions(),
                              ),
                              SizedBox(width: spacing.sm),
                              _AccentDots(colors: colors),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is TripsSuccess && state.trips.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          spacing.lg,
                          spacing.md,
                          spacing.lg,
                          spacing.sm,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'JOURNALS',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(width: spacing.sm),
                            Expanded(
                              child: Divider(color: colors.hairline),
                            ),
                            SizedBox(width: spacing.sm),
                            Text(
                              '${state.trips.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: colors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state is TripsLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is TripsError)
                    SliverFillRemaining(
                      child: _MessagePane(
                        title: 'Couldn’t load trips',
                        body: state.failure.message,
                        actionLabel: 'Retry',
                        onAction: () => context
                            .read<TripsBloc>()
                            .add(const LoadTrips(seedDemo: false)),
                      ),
                    )
                  else if (state is TripsEmpty)
                    SliverFillRemaining(
                      child: _MessagePane(
                        title: 'Blank atlas',
                        body:
                            'Your first trip becomes the cover of this journal.',
                        actionLabel: 'Create trip',
                        onAction: () async {
                          final created =
                              await context.push<bool>('/trips/new');
                          if (created == true && context.mounted) {
                            context
                                .read<TripsBloc>()
                                .add(const RefreshTrips());
                          }
                        },
                      ),
                    )
                  else if (state is TripsSuccess)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.lg,
                        spacing.sm,
                        spacing.lg,
                        spacing.section,
                      ),
                      sliver: SliverList.separated(
                        itemCount: state.trips.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: spacing.lg),
                        itemBuilder: (context, index) {
                          final trip = state.trips[index];
                          final isExample = trip.id == AppPrefs.exampleTripId;
                          final card = TripCard(
                            trip: trip,
                            index: index,
                            isExample: isExample,
                            onTap: () => context.push('/trips/${trip.id}'),
                            onDelete: () {
                              context
                                  .read<TripsBloc>()
                                  .add(RemoveTrip(trip.id));
                            },
                          );

                          if (index == 0) {
                            return Showcase(
                              key: _exampleTripKey,
                              title: 'Example trip',
                              description:
                                  'This is a sample journal so you can see how '
                                  'Orbit works. Open it to explore days and '
                                  'entries, or swipe left / tap delete to remove it.',
                              titleTextStyle: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: colors.ink,
                              ),
                              descTextStyle: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                height: 1.4,
                                color: colors.body,
                              ),
                              tooltipBackgroundColor: colors.canvas,
                              child: card,
                            );
                          }
                          return card;
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignedInAsLine extends StatelessWidget {
  const _SignedInAsLine();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, next) =>
          prev.runtimeType != next.runtimeType ||
          (prev is AuthAuthenticated &&
              next is AuthAuthenticated &&
              prev.user != next.user),
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: spacing.md),
          child: Text(
            state.user.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
          ),
        );
      },
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OrbitButton(
                label: 'Sync',
                variant: OrbitButtonVariant.secondary,
                icon: Icons.cloud_sync_outlined,
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSyncRequested());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Syncing as ${state.user.email}…'),
                    ),
                  );
                  context.read<TripsBloc>().add(const RefreshTrips());
                },
              ),
              const SizedBox(width: 8),
              OrbitButton(
                label: 'Out',
                variant: OrbitButtonVariant.text,
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const AuthSignOutRequested()),
              ),
            ],
          );
        }

        return OrbitButton(
          label: 'Sign in',
          variant: OrbitButtonVariant.secondary,
          icon: Icons.person_outline,
          onPressed: () => context.push('/login'),
        );
      },
    );
  }
}

class _AccentDots extends StatelessWidget {
  const _AccentDots({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final dots = [
      colors.brandPink,
      colors.brandLavender,
      colors.brandPeach,
      colors.brandOchre,
    ];
    return Row(
      children: [
        for (var i = 0; i < dots.length; i++)
          Transform.translate(
            offset: Offset(-i * 6.0, 0),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: dots[i],
                shape: BoxShape.circle,
                border: Border.all(color: colors.canvas, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _MessagePane extends StatelessWidget {
  const _MessagePane({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radii = context.radii;
    return Padding(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colors.brandPeach.withValues(alpha: 0.45),
              borderRadius: radii.xlRadius,
            ),
            child: CustomPaint(
              painter:
                  _EmptyOrbitPainter(color: colors.ink.withValues(alpha: 0.35)),
            ),
          ),
          SizedBox(height: spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.muted,
                ),
          ),
          SizedBox(height: spacing.lg),
          OrbitButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}

class _EmptyOrbitPainter extends CustomPainter {
  _EmptyOrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color;
    canvas.drawCircle(c, 18, paint);
    canvas.drawCircle(c, 28, paint..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _EmptyOrbitPainter oldDelegate) => false;
}
