import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  Future<void> saveEmail(String email) async => await _prefs.setString('email', email);
  String getEmail() => _prefs.getString('email') ?? '';

  Future<void> savePassword(String password) async => await _prefs.setString('password', password);
  String getPassword() => _prefs.getString('password') ?? '';
}