import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/auth/domain/entities/orbit_user.dart';
import 'package:orbit_notes/features/auth/domain/usecases/auth_usecases.dart';
import 'package:orbit_notes/features/notes/data/sync/orbit_cloud_sync.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required OrbitCloudSync cloudSync,
  })  : _watchAuthState = watchAuthState,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _cloudSync = cloudSync,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<_AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthSyncRequested>(_onSync);
  }

  final WatchAuthState _watchAuthState;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final OrbitCloudSync _cloudSync;
  StreamSubscription<OrbitUser?>? _subscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _subscription?.cancel();
    _subscription = _watchAuthState().listen(
      (user) => add(_AuthUserChanged(user)),
    );
    add(_AuthUserChanged(_watchAuthState.currentUser));
  }

  Future<void> _onUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(AuthAuthenticated(user));
    unawaited(_cloudSync.syncBidirectional());
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
      unawaited(_cloudSync.syncBidirectional());
    } on Failure catch (failure) {
      emit(AuthFailureState(failure.message));
    } catch (_) {
      emit(const AuthFailureState('Could not sign in. Please try again.'));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signUpWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
      unawaited(_cloudSync.syncBidirectional());
    } on Failure catch (failure) {
      emit(AuthFailureState(failure.message));
    } catch (_) {
      emit(const AuthFailureState('Could not create account. Please try again.'));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogle();
      emit(AuthAuthenticated(user));
      unawaited(_cloudSync.syncBidirectional());
    } on Failure catch (failure) {
      emit(AuthFailureState(failure.message));
    } catch (_) {
      emit(const AuthFailureState('Google sign-in failed.'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _signOut();
      emit(const AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(AuthFailureState(failure.message));
    } catch (_) {
      emit(const AuthFailureState('Could not sign out.'));
    }
  }

  Future<void> _onSync(
    AuthSyncRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    try {
      await _cloudSync.syncBidirectional();
      emit(AuthAuthenticated(current.user, syncedAt: DateTime.now()));
    } on Failure catch (failure) {
      emit(AuthFailureState(failure.message));
      emit(current);
    } catch (_) {
      emit(const AuthFailureState('Sync failed.'));
      emit(current);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
