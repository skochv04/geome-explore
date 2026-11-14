import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart';

// Wiersz w `profiles` tworzy trigger `handle_new_user` przy rejestracji.
class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  SupabaseClient get _db => Supabase.instance.client;

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

  Future<void> updateUsername(String username) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    await _db
        .from('profiles')
        .update({'username': username.trim()})
        .eq('id', user.id);
  }
}
