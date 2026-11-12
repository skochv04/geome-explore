import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

/// Warstwa dostępu do tabeli `profiles`.
class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  SupabaseClient get _db => Supabase.instance.client;

  /// Pobiera profil zalogowanego użytkownika (albo null, gdy go nie ma).
  Future<Profile?> getCurrentProfile() async {
    final user = _db.auth.currentUser;
    if (user == null) return null;

    final row = await _db
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return row == null ? null : Profile.fromMap(row);
  }

  /// Tworzy wiersz w `profiles` dla zalogowanego użytkownika, jeśli jeszcze go nie ma.
  /// Username bierzemy z metadanych podanych przy rejestracji.
  ///
  /// Jeśli w bazie jest trigger, który sam tworzy profil po rejestracji,
  /// ta metoda po prostu nic nie zrobi (wiersz już istnieje).
  Future<void> ensureProfileExists() async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    final username = (user.userMetadata?['username'] as String?) ??
        user.email!.split('@').first;

    // upsert + ignoreDuplicates = "INSERT ... ON CONFLICT (id) DO NOTHING":
    // istniejący profil nie zostanie nadpisany, a dwa równoczesne wywołania
    // (np. z ekranu rejestracji i z ekranu profilu) nie spowodują błędu.
    await _db.from('profiles').upsert(
      {'id': user.id, 'username': username},
      onConflict: 'id',
      ignoreDuplicates: true,
    );
  }

  Future<void> updateUsername(String username) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    await _db
        .from('profiles')
        .update({'username': username.trim()})
        .eq('id', user.id);
  }
}
