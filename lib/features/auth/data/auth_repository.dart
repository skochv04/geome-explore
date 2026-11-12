import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/data/profile_repository.dart';

/// Warstwa dostępu do Supabase Auth (rejestracja, logowanie, wylogowanie).
/// Ekrany nie wołają Supabase bezpośrednio – tylko przez to repozytorium.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentSession != null;

  /// Strumień zmian stanu logowania (zalogowanie, wylogowanie, odświeżenie tokenu).
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Rejestruje użytkownika.
  ///
  /// Zwraca `true`, jeśli użytkownik jest od razu zalogowany,
  /// `false` – jeśli Supabase wymaga potwierdzenia adresu e-mail.
  /// Username zapisujemy też w metadanych konta, żeby móc utworzyć
  /// wiersz w `profiles` przy pierwszym logowaniu (gdy jest potwierdzenie e-mail).
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

    if (res.session == null) return false;

    await ProfileRepository.instance.ensureProfileExists();
    return true;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
    await ProfileRepository.instance.ensureProfileExists();
  }

  Future<void> signOut() => _auth.signOut();
}

/// Zamienia wyjątek na czytelny komunikat do wyświetlenia w SnackBarze.
String errorMessage(Object e) {
  if (e is AuthException) return e.message;
  if (e is PostgrestException) return e.message;
  return 'Something went wrong. Please try again.';
}
