import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/routing/go_router_refresh_stream.dart';
import 'package:orbit_notes/core/theme/app_theme.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:orbit_notes/features/auth/presentation/pages/login_page.dart';
import 'package:orbit_notes/features/auth/presentation/pages/signup_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/create_trip_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/entry_editor_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/trip_detail_page.dart';
import 'package:orbit_notes/features/notes/presentation/pages/trips_home_page.dart';

class OrbitApp extends StatelessWidget {
  OrbitApp({super.key});

  final AuthBloc _authBloc = getIt<AuthBloc>();

  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    routes: [
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
