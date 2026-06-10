import 'dart:convert';

/// Helper untuk decode JWT secara lokal tanpa library eksternal.
/// JWT terdiri dari 3 bagian: header.payload.signature (base64url encoded).
/// Kita hanya perlu payload untuk mengecek masa berlaku token.
class JwtHelper {
  /// Refresh proaktif dijadwalkan saat sisa masa berlaku token <= nilai ini.
  static const int refreshThresholdMinutes = 5;

  /// Decode payload JWT dan kembalikan sebagai Map.
  /// Mengembalikan null jika format token tidak valid.
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64url → Base64 (tambah padding '=' jika perlu)
      String payload = parts[1];
      final remainder = payload.length % 4;
      if (remainder != 0) {
        payload = payload.padRight(payload.length + (4 - remainder), '=');
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Ambil waktu kadaluarsa token (exp) sebagai DateTime.
  /// Mengembalikan null jika token tidak valid atau tidak memiliki field 'exp'.
  static DateTime? getExpiry(String token) {
    final payload = decodePayload(token);
    if (payload == null || payload['exp'] == null) return null;
    final expSeconds = payload['exp'] as int;
    return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
  }

  /// Cek apakah token sudah expired.
  static bool isExpired(String token) {
    final expiry = getExpiry(token);
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Cek apakah token akan expire dalam waktu kurang dari [thresholdMinutes] menit.
  /// Berguna untuk proactive refresh sebelum token benar-benar mati.
  static bool isExpiringSoon(
    String token, {
    int thresholdMinutes = refreshThresholdMinutes,
  }) {
    final expiry = getExpiry(token);
    if (expiry == null) return true;
    final threshold = DateTime.now().add(Duration(minutes: thresholdMinutes));
    return expiry.isBefore(threshold);
  }

  /// Kembalikan sisa waktu token dalam Duration.
  /// Mengembalikan Duration.zero jika sudah expired.
  static Duration remainingTime(String token) {
    final expiry = getExpiry(token);
    if (expiry == null) return Duration.zero;
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Status token dalam bentuk string untuk debugging.
  static String tokenStatus(String token) {
    final expiry = getExpiry(token);
    if (expiry == null) return 'INVALID';
    if (isExpired(token)) return 'EXPIRED';
    if (isExpiringSoon(token)) {
      return 'EXPIRING_SOON (< ${refreshThresholdMinutes}m)';
    }
    final remaining = remainingTime(token);
    return 'VALID (sisa ${remaining.inMinutes}m ${remaining.inSeconds % 60}s)';
  }
}
