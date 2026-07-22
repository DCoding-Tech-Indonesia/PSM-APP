import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'userId';
  static const _keyUserRoleId = 'userRoleId';
  static const _keyUsername = 'username';
  static const _keyEmailCred = 'email';
  static const _keyUsernameCred = 'usernameCred';
  static const _keyPassCred = 'passwordCred';
  static const _idTimeTableRitase = 'idTimeTableRitase';
  static const _keyFirstLogin = 'firstLogin';
  static const _keyPramugaraId = 'pramugaraId';
  static const _keyKorlapId = 'korlapId';
  static const _keyPegawaiId = 'pegawaiId';

  Future<void> saveEmailCred(String email) =>
      _storage.write(key: _keyEmailCred, value: email);
  Future<String?> readEmailCred() async {
    String? value = await _storage.read(key: _keyEmailCred);
    return value;
  }

  Future<void> saveUsernameCred(String username) =>
      _storage.write(key: _keyUsernameCred, value: username);
  Future<String?> readUsernameCred() async {
    String? value = await _storage.read(key: _keyUsernameCred);
    return value;
  }

  Future<void> savePassCred(String password) =>
      _storage.write(key: _keyPassCred, value: password);
  Future<String?> readPassCred() async {
    String? value = await _storage.read(key: _keyPassCred);
    return value;
  }
  Future<void> clearPassCred() =>
      _storage.delete(key: _keyPassCred);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);
  Future<String?> readAccessToken() async {
    String? value = await _storage.read(key: _keyAccessToken);
    return value;
  }

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);
  Future<String?> readRefreshToken() async {
    String? value = await _storage.read(key: _keyRefreshToken);
    return value;
  }

  Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);
  Future<String?> readUserId() async {
    String? value = await _storage.read(key: _keyUserId);
    return value;
  }

  Future<void> saveUserRoleIdId(String id) =>
      _storage.write(key: _keyUserRoleId, value: id);
  Future<String?> readUserRoleId() async {
    String? value = await _storage.read(key: _keyUserRoleId);
    return value;
  }

  Future<void> saveUsername(String username) =>
      _storage.write(key: _keyUsername, value: username);
  Future<String?> readUsername() async {
    String? value = await _storage.read(key: _keyUsername);
    return value;
  }

  Future<void> saveIdTimeTableRitase(String id) =>
      _storage.write(key: _idTimeTableRitase, value: id);
  Future<String?> readIdTimeTableRitase() async {
    String? value = await _storage.read(key: _idTimeTableRitase);
    return value;
  }

  Future<void> saveFirstLogin(bool value) =>
      _storage.write(key: _keyFirstLogin, value: value.toString());
  Future<bool> readFirstLogin() async {
    String? value = await _storage.read(key: _keyFirstLogin);
    return value == 'true';
  }
  Future<void> clearFirstLogin() =>
      _storage.delete(key: _keyFirstLogin);

  Future<void> savePramugaraId(String id) =>
      _storage.write(key: _keyPramugaraId, value: id);
  Future<String?> readPramugaraId() async {
    String? value = await _storage.read(key: _keyPramugaraId);
    return value;
  }

  Future<void> saveKorlapId(String id) =>
      _storage.write(key: _keyKorlapId, value: id);
  Future<String?> readKorlapId() async {
    String? value = await _storage.read(key: _keyKorlapId);
    return value;
  }

  Future<void> savePegawaiId(String id) =>
      _storage.write(key: _keyPegawaiId, value: id);
  Future<String?> readPegawaiId() async {
    String? value = await _storage.read(key: _keyPegawaiId);
    return value;
  }

  Future<String?> getActiveUserId() async {
    final pramugaraId = await readPramugaraId();
    if (pramugaraId != null && pramugaraId.isNotEmpty) return pramugaraId;

    final korlapId = await readKorlapId();
    if (korlapId != null && korlapId.isNotEmpty) return korlapId;

    final pegawaiId = await readPegawaiId();
    if (pegawaiId != null && pegawaiId.isNotEmpty) return pegawaiId;

    return null;
  }

  Future<void> clearLogin() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserRoleId),
      _storage.delete(key: _keyUsername),
      _storage.delete(key: _keyFirstLogin),
      _storage.delete(key: _keyPramugaraId),
      _storage.delete(key: _keyKorlapId),
      _storage.delete(key: _keyPegawaiId),
    ]);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
