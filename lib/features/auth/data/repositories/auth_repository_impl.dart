import 'package:orbit_notes/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:orbit_notes/features/auth/domain/entities/orbit_user.dart';
import 'package:orbit_notes/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  OrbitUser? get currentUser => _remote.currentUser;

  @override
  Stream<OrbitUser?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<OrbitUser> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _remote.signInWithEmail(email: email, password: password);

  @override
  Future<OrbitUser> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _remote.signUpWithEmail(email: email, password: password);

  @override
  Future<OrbitUser> signInWithGoogle() => _remote.signInWithGoogle();

  @override
  Future<void> signOut() => _remote.signOut();
}
