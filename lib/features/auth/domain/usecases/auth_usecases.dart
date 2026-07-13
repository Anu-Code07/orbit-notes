import 'package:orbit_notes/features/auth/domain/entities/orbit_user.dart';
import 'package:orbit_notes/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<OrbitUser> call({
    required String email,
    required String password,
  }) =>
      _repository.signInWithEmail(email: email, password: password);
}

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<OrbitUser> call({
    required String email,
    required String password,
  }) =>
      _repository.signUpWithEmail(email: email, password: password);
}

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<OrbitUser> call() => _repository.signInWithGoogle();
}

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<OrbitUser?> call() => _repository.authStateChanges;

  OrbitUser? get currentUser => _repository.currentUser;
}
