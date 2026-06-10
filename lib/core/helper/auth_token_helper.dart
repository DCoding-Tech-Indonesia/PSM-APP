import 'package:psm_mobile/core/storage/secure_storage.dart';

class AuthTokenHelper {
  /// Parse access + refresh token dari field `data` response auth API.
  static ({String? accessToken, String? refreshToken}) parseFromData(
    dynamic data,
  ) {
    dynamic item;
    if (data is List && data.isNotEmpty) {
      item = data[0];
    } else if (data is Map) {
      item = data;
    }

    if (item is! Map) {
      return (accessToken: null, refreshToken: null);
    }

    final access = item['token']?.toString();
    final refresh = item['refreshToken']?.toString();
    return (accessToken: access, refreshToken: refresh);
  }

  /// Simpan access token. Refresh token hanya di-update jika backend mengirim nilai baru.
  static Future<void> saveTokens(
    SecureStorageService storage, {
    required String accessToken,
    String? refreshToken,
  }) async {
    await storage.saveAccessToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await storage.saveRefreshToken(refreshToken);
    }
  }
}
