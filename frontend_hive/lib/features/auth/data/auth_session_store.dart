import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStore {
  const AuthSessionStore();

  static const _tokenKey = 'afyahive_access_token';
  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
