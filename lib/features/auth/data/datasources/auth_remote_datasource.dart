import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:orbit_notes/core/config/supabase_config.dart';
import 'package:orbit_notes/core/failure/failure.dart';
import 'package:orbit_notes/features/auth/domain/entities/orbit_user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    SupabaseClient? client,
    GoogleSignIn? googleSignIn,
  })  : _client = client ?? Supabase.instance.client,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;
  bool _googleReady = false;

  OrbitUser? get currentUser => _mapUser(_client.auth.currentUser);

  Stream<OrbitUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => _mapUser(event.session?.user));

  Future<OrbitUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AuthFailure('Signed in, but no user was returned.');
      }
      return user;
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } catch (_) {
      throw const AuthFailure();
    }
  }

  Future<OrbitUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AuthFailure(
          'Check your email to confirm the account, then sign in.',
        );
      }
      if (response.session == null) {
        throw const AuthFailure(
          'Account created. Confirm your email, then sign in.',
        );
      }
      return user;
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure();
    }
  }

  Future<OrbitUser> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          'Google did not return an ID token. Check the Web client ID setup.',
        );
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AuthFailure('Google sign-in succeeded without a user.');
      }
      return user;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error.message));
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Google sign-in was cancelled.');
      }
      throw AuthFailure(error.description ?? 'Google sign-in failed.');
    } catch (_) {
      throw const AuthFailure('Google sign-in failed.');
    }
  }

  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Local Google session clear is best-effort.
    }
    await _client.auth.signOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    await _googleSignIn.initialize(
      serverClientId: SupabaseConfig.googleWebClientId,
    );
    _googleReady = true;
  }

  OrbitUser? _mapUser(User? user) {
    if (user == null) return null;
    final email = user.email;
    if (email == null || email.isEmpty) return null;
    return OrbitUser(id: user.id, email: email);
  }

  String _friendlyAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login')) {
      return 'Email or password is incorrect.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Confirm your email before signing in.';
    }
    if (lower.contains('user already registered')) {
      return 'That email is already registered. Try signing in.';
    }
    if (lower.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    return message;
  }
}
