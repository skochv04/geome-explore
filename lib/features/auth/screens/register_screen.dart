import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/auth_repository.dart';
import '../validators.dart';
import 'login_screen.dart';

/// Ekran rejestracji.
/// - Jeśli Supabase loguje od razu – zamykamy ekran (użytkownik jest zalogowany).
/// - Jeśli wymagane jest potwierdzenie e-mail – pokazujemy komunikat
///   i przechodzimy do logowania.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final loggedIn = await AuthRepository.instance.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );
      if (!mounted) return;

      if (loggedIn) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Check your email to confirm the account, then log in.'),
        ));
        _goToLogin();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(e))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                textInputAction: TextInputAction.next,
                validator: Validators.username,
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                isPassword: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: Validators.password,
              ),
              AppTextField(
                controller: _confirmController,
                label: 'Confirm password',
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signUp(),
                validator: (v) => v != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Create account',
                isLoading: _isLoading,
                onPressed: _signUp,
              ),
              TextButton(
                onPressed: _isLoading ? null : _goToLogin,
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
