import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentSession != null;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // false = Supabase wymaga potwierdzenia e-mail (brak sesji).
  // username odczytuje trigger `handle_new_user` z metadanych.
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'username': username.trim()},
    );

    return res.session != null;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() => _auth.signOut();
}

String errorMessage(Object e) {
  debugPrint('Error: $e');
  if (e is AuthException) return e.message;
  if (e is PostgrestException) return e.message;
  if (kDebugMode) return e.toString();
  return 'Something went wrong. Please try again.';
}
