import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _appVersionKey = 'app_version';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }

  static Future<String?> getAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appVersionKey);
  }

  static Future<void> setAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appVersionKey, version);
  }

  static Future<bool> shouldShowOnboarding(String currentVersion) async {
    final completed = await isOnboardingCompleted();
    final savedVersion = await getAppVersion();

    // Show onboarding if never completed or app version changed
    return !completed || savedVersion != currentVersion;
  }

  static Future<void> markOnboardingShown(String currentVersion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    await prefs.setString(_appVersionKey, currentVersion);
  }
}
