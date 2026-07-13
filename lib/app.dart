import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/core/routing/go_router_refresh_stream.dart';
import 'package:orbit_notes/core/theme/app_theme.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:orbit_notes/features/auth/presentation/pages/login_page.dart';
import 'package:orbit_notes/features/auth/presentation/pages/signup_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/create_trip_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/entry_editor_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/plan_trip_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/trip_detail_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/trips_home_page.dart';
import 'package:orbit_notes/features/splash/presentation/pages/splash_page.dart';

class OrbitApp extends StatefulWidget {
  const OrbitApp({super.key});

  @override
  State<OrbitApp> createState() => _OrbitAppState();
}

class _OrbitAppState extends State<OrbitApp> {
  final AuthBloc _authBloc = getIt<AuthBloc>();
  final AppPrefs _prefs = getIt<AppPrefs>();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    ShowcaseView.register(
      blurValue: 1.2,
      autoPlayDelay: const Duration(seconds: 4),
      onFinish: () {
        _prefs.markHomeTourSeen();
      },
      onDismiss: (_) {
        _prefs.markHomeTourSeen();
      },
    );

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
      redirect: (context, state) {
        final location = state.matchedLocation;
        if (location == '/splash') return null;
        final onAuth = location == '/login' || location == '/signup';
        if (!_prefs.hasCompletedAuthGate && !onAuth) {
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const TripsHomePage(),
        ),
        GoRoute(
          path: '/trips/new',
          builder: (context, state) => const CreateTripPage(),
        ),
        GoRoute(
          path: '/trips/plan',
          builder: (context, state) => const PlanTripPage(),
        ),
        GoRoute(
          path: '/trips/:tripId',
          builder: (context, state) => TripDetailPage(
            tripId: state.pathParameters['tripId']!,
          ),
        ),
        GoRoute(
          path: '/trips/:tripId/days/:dayId/entries/new',
          builder: (context, state) => EntryEditorPage(
            tripId: state.pathParameters['tripId']!,
            dayId: state.pathParameters['dayId']!,
          ),
        ),
        GoRoute(
          path: '/trips/:tripId/days/:dayId/entries/:entryId',
          builder: (context, state) => EntryEditorPage(
            tripId: state.pathParameters['tripId']!,
            dayId: state.pathParameters['dayId']!,
            entryId: state.pathParameters['entryId'],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Orbit Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
      ),
    );
  }
}
