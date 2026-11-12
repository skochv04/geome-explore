/// Walidatory pól formularzy logowania i rejestracji.
/// Zwracają komunikat błędu albo null, gdy wartość jest poprawna.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  /// Supabase domyślnie wymaga co najmniej 6 znaków.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  /// W tabeli `profiles` username to varchar(50).
  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 50) return 'At most 50 characters';
    return null;
  }
}
