import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserJson = 'user_json';

  Future<void> saveAccessToken(String token) => _storage.write(key: _keyAccessToken, value: token);
  Future<String?> readAccessToken() => _storage.read(key: _keyAccessToken);

  Future<void> saveRefreshToken(String token) => _storage.write(key: _keyRefreshToken, value: token);
  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> saveUserJson(String json) => _storage.write(key: _keyUserJson, value: json);
  Future<String?> readUserJson() => _storage.read(key: _keyUserJson);

  Future<void> clearAll() => _storage.deleteAll();
}