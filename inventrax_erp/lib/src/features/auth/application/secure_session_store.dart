import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists Supabase refresh token for "Remember me" / auto-login.
class SecureSessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _refreshKey = 'inventrax_sb_refresh';
  static const _emailKey = 'inventrax_remember_email';

  Future<void> saveRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _storage.delete(key: _refreshKey);
      return;
    }
    await _storage.write(key: _refreshKey, value: token);
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _emailKey);
  }

  Future<void> saveRememberEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _storage.delete(key: _emailKey);
      return;
    }
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> readRememberEmail() => _storage.read(key: _emailKey);
}
