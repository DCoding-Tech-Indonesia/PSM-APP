import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'userId';
  static const _keyUsername = 'username';
  static const _keyEmailCred = 'email';
  static const _keyUsernameCred = 'usernameCred';
  static const _keyPassCred = 'passwordCred';

  Future<void> saveEmailCred(String email) => _storage.write(key: _keyEmailCred, value: email);
  Future<String?> readEmailCred() async {
    String? value = await _storage.read(key: _keyEmailCred);
    return value;
  }

  Future<void> saveUsernameCred(String username) => _storage.write(key: _keyUsernameCred, value: username);
  Future<String?> readUsernameCred() async {
    String? value = await _storage.read(key: _keyUsernameCred);
    return value;
  }

  Future<void> savePassCred(String password) => _storage.write(key: _keyPassCred, value: password);
  Future<String?> readPassCred() async {
    String? value = await _storage.read(key: _keyPassCred);
    return value;
  }

  Future<void> saveAccessToken(String token) => _storage.write(key: _keyAccessToken, value: token);
  Future<String?> readAccessToken() async {
    String? value = await _storage.read(key: _keyAccessToken);
    return value;
  }

  Future<void> saveRefreshToken(String token) => _storage.write(key: _keyRefreshToken, value: token);
  Future<String?> readRefreshToken() async {
    String? value = await _storage.read(key: _keyRefreshToken);
    return value;
  }

  Future<void> saveUserId(String id) => _storage.write(key: _keyUserId, value: id);
  Future<String?> readUserId() async {
    String? value = await _storage.read(key: _keyUserId);
    return value;
  }

  Future<void> saveUsername(String username) => _storage.write(key: _keyUsername, value: username);
  Future<String?> readUsername() async {
    String? value = await _storage.read(key: _keyUsername);
    return value;
  }

  Future<void> clearLogin() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUsername),
    ]);
  }

  Future<void> clearAll() => _storage.deleteAll();
}