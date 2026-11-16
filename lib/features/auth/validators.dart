abstract final class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 50) return 'At most 50 characters';
    return null;
  }
}
