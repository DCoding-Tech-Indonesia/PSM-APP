import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:travis/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late SharedPreferences _prefs;
  final LocalAuthentication auth = LocalAuthentication();

  static const _apiBaseUrlKey = 'API_BASE_URL';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final envApiUrl = AppConfig.apiBaseUrl;

    if (!_prefs.containsKey(_apiBaseUrlKey)) {
      await _prefs.setString(_apiBaseUrlKey, envApiUrl);
    }

    await handleFingerprint();
  }

  Future<void> handleFingerprint() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final List<BiometricType> biometrics = await auth.getAvailableBiometrics();

      final bool hasValue = _prefs.containsKey('biometric');

      if (!hasValue) {
        if (isSupported && canCheckBiometrics && biometrics.isNotEmpty) {
          await _prefs.setBool('biometric', true);
        } else {
          await _prefs.setBool('biometric', false);
        }
      }

    } on PlatformException catch (e) {
      debugPrint('[ERROR] [SHARED_PREFERENCES] [HANDLE_FINGERPRINT] : ${e.message}');
    }
  }

  Future<void> toggleBiometric(bool value) async => await _prefs.setBool('biometric', value);
  bool getBiometric() => _prefs.getBool('biometric') ?? false;
}