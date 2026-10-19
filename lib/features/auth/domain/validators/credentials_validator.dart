abstract final class CredentialsValidator {
  static const int minPasswordLength = 6;

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );

  static String? validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }

  static bool isValid({required String email, required String password}) =>
      validateEmail(email) == null && validatePassword(password) == null;
}
