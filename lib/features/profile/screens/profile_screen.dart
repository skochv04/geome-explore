import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../auth/validators.dart';
import '../data/profile.dart';
import '../data/profile_repository.dart';

/// Zakładka Profile.
/// Słucha zmian stanu logowania: niezalogowany widzi przyciski
/// Log in / Sign up, zalogowany – swój profil.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthRepository.instance.authStateChanges,
      builder: (context, _) {
        if (!AuthRepository.instance.isLoggedIn) return const _GuestView();
        // Klucz = id użytkownika, żeby po zmianie konta profil wczytał się od nowa.
        return _UserView(key: ValueKey(AuthRepository.instance.currentUser!.id));
      },
    );
  }
}

/// Widok dla niezalogowanego użytkownika.
class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Log in to create posts, save them and see your profile.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Log in',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Sign up',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widok profilu zalogowanego użytkownika.
class _UserView extends StatefulWidget {
  const _UserView({super.key});

  @override
  State<_UserView> createState() => _UserViewState();
}

class _UserViewState extends State<_UserView> {
  late Future<Profile?> _profileFuture = _loadProfile();

  Future<Profile?> _loadProfile() async {
    // Na wypadek gdyby wiersz w `profiles` jeszcze nie istniał.
    await ProfileRepository.instance.ensureProfileExists();
    return ProfileRepository.instance.getCurrentProfile();
  }

  void _reload() => setState(() => _profileFuture = _loadProfile());

  Future<void> _editUsername(String current) async {
    final newUsername = await showDialog<String>(
      context: context,
      builder: (_) => _EditUsernameDialog(initial: current),
    );
    if (newUsername == null || newUsername == current) return;

    try {
      await ProfileRepository.instance.updateUsername(newUsername);
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  Future<void> _logOut() async {
    try {
      await AuthRepository.instance.signOut();
      // StreamBuilder w ProfileScreen sam przełączy widok na _GuestView.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthRepository.instance.currentUser?.email ?? '';

    return SafeArea(
      child: FutureBuilder<Profile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.hasError
                          ? errorMessage(snapshot.error!)
                          : 'Profile not found.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton(label: 'Try again', onPressed: _reload),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Log out',
                      variant: AppButtonVariant.secondary,
                      onPressed: _logOut,
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          final initial = profile.username.isNotEmpty
              ? profile.username[0].toUpperCase()
              : '?';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(initial, style: const TextStyle(fontSize: 32))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Username'),
                subtitle: Text(profile.username),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit username',
                  onPressed: () => _editUsername(profile.username),
                ),
              ),
              ListTile(title: const Text('Email'), subtitle: Text(email)),
              ListTile(
                title: const Text('Member since'),
                subtitle: Text(
                  profile.createdAt.toLocal().toString().split(' ').first,
                ),
              ),
              const Divider(),
              // TODO (tydzień 6): lista "My posts".
              const SizedBox(height: 24),
              AppButton(
                label: 'Log out',
                icon: Icons.logout,
                variant: AppButtonVariant.secondary,
                onPressed: _logOut,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Okno dialogowe do zmiany username.
class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({required this.initial});

  final String initial;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit username'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: 'Username',
          validator: Validators.username,
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
