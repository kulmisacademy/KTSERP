class AuthException implements Exception {
  AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;

  static AuthException fromSupabase(Object error) {
    final text = error.toString();
    if (text.contains('Invalid login credentials')) {
      return AuthException('Invalid email or password', code: 'invalid_credentials');
    }
    if (text.contains('User already registered') ||
        text.contains('already been registered')) {
      return AuthException(
        'This email already has a login. Use the same password as Sign in, or Forgot password.',
        code: 'existing_account',
      );
    }
    if (text.contains('Email not confirmed')) {
      return AuthException(
        'Please confirm your email, then sign in',
        code: 'email_not_confirmed',
      );
    }
    if (text.contains('Account already registered')) {
      return AuthException('This account is already linked to a store', code: 'already_registered');
    }
    if (text.contains('Phone not verified')) {
      return AuthException(
        'Registration could not be completed. Please try again.',
        code: 'registration_failed',
      );
    }
    if (text.contains('Valid phone number is required')) {
      return AuthException('A valid phone number is required', code: 'phone_required');
    }
    if (text.contains('Network') || text.contains('SocketException')) {
      return AuthException('Network error. Check your connection and try again', code: 'network');
    }
    return AuthException(
      'Could not complete registration. Check your password and try again.',
      code: 'registration_failed',
    );
  }
}
