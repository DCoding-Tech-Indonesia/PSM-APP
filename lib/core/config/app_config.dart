import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const env =
  String.fromEnvironment('ENV', defaultValue: 'DEV');

  static String get apiBaseUrl {
    switch (env) {
      case 'PROD':
        return dotenv.env['API_BASE_URL_PROD'] ?? '';

      case 'DEV':
      default:
        return dotenv.env['API_BASE_URL_DEV'] ?? '';
    }
  }
}