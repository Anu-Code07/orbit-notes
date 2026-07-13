import 'package:orbit_notes/features/auth/domain/entities/orbit_user.dart';

abstract class AuthRepository {
  OrbitUser? get currentUser;

  Stream<OrbitUser?> get authStateChanges;

  Future<OrbitUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<OrbitUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<OrbitUser> signInWithGoogle();

  Future<void> signOut();
}
