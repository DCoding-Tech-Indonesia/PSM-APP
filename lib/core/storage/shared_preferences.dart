import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences _prefs;

  static const _apiBaseUrlKey = 'API_BASE_URL';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final envApiUrl = dotenv.env['API_BASE_URL'] ?? '';

    if (!_prefs.containsKey(_apiBaseUrlKey)) {
      await _prefs.setString(_apiBaseUrlKey, envApiUrl);
    }
  }

  Future<void> saveEmail(String email) async => await _prefs.setString('email', email);
  String getEmail() => _prefs.getString('email') ?? '';

  Future<void> savePassword(String password) async => await _prefs.setString('password', password);
  String getPassword() => _prefs.getString('password') ?? '';
}