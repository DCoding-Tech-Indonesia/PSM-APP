import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:psm_mobile/core/helper/auth_token_helper.dart';
import 'package:psm_mobile/core/helper/jwt_helper.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';

class DioClient {
  DioClient._internal();
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  Dio get instance => _dio;
  VoidCallback? onUnauthorized;

  void init({String? baseUrl, String? token, VoidCallback? onUnauthorized}) {
    this.onUnauthorized = onUnauthorized;
    final resolvedBaseUrl = baseUrl ?? dotenv.env['API_BASE_URL'] ?? '';

    _dio = Dio(
      BaseOptions(
        baseUrl: resolvedBaseUrl,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );

    _addInterceptors();
  }

  bool _isRefreshing = false;
  Timer? _refreshTimer;

  /// Jadwalkan refresh token proaktif sebelum token expired.
  /// Dipanggil setelah login atau setelah refresh berhasil.
  void scheduleProactiveRefresh(String token) {
    _refreshTimer?.cancel();

    final remaining = JwtHelper.remainingTime(token);
    if (remaining == Duration.zero) {
      if (kDebugMode) {
        debugPrint('[PROACTIVE] Token sudah expired, skip schedule');
      }
      return;
    }

    // Refresh 5 menit sebelum expired (atau segera jika sisa < 5 menit)
    const threshold = Duration(minutes: JwtHelper.refreshThresholdMinutes);
    final delay = remaining > threshold ? remaining - threshold : Duration.zero;

    if (kDebugMode) {
      debugPrint(
        '[PROACTIVE] Refresh dijadwalkan dalam ${delay.inMinutes}m ${delay.inSeconds % 60}s '
        '(token: ${JwtHelper.tokenStatus(token)})',
      );
    }

    _refreshTimer = Timer(delay, () async {
      await _doProactiveRefresh();
    });
  }

  /// Batalkan timer proaktif (saat logout).
  void cancelProactiveRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (kDebugMode) debugPrint('[PROACTIVE] Timer dibatalkan');
  }

  /// Eksekusi refresh token secara proaktif di background.
  Future<void> _doProactiveRefresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    if (kDebugMode) debugPrint('[PROACTIVE] Mulai refresh token proaktif...');

    final secureStorage = SecureStorageService();
    String? accessToken;

    try {
      accessToken = await secureStorage.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('[PROACTIVE] Access token kosong, force logout');
        }
        onUnauthorized?.call();
        return;
      }

      final refreshToken = await secureStorage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) debugPrint('[PROACTIVE] Refresh token kosong, skip');
        return;
      }

      if (JwtHelper.isExpired(refreshToken)) {
        if (kDebugMode) {
          debugPrint('[PROACTIVE] Refresh token expired, force logout');
        }
        onUnauthorized?.call();
        return;
      }

      // Gunakan token Dio baru agar tidak terganggu interceptor
      final tokenDio = Dio(
        BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''),
      );

      final response = await tokenDio.post(
        '/auth/refresh',
        queryParameters: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == true) {
          final tokens = AuthTokenHelper.parseFromData(response.data['data']);

          if (tokens.accessToken != null) {
            await AuthTokenHelper.saveTokens(
              secureStorage,
              accessToken: tokens.accessToken!,
              refreshToken: tokens.refreshToken,
            );
            setAuthToken(tokens.accessToken!);
            if (kDebugMode) {
              debugPrint(
                '[PROACTIVE] Token berhasil diperbarui, jadwalkan ulang...',
              );
            }
            scheduleProactiveRefresh(tokens.accessToken!);
            return;
          }

          if (kDebugMode) {
            debugPrint(
              '[PROACTIVE] Response sukses tapi token tidak ditemukan',
            );
          }
        } else {
          // Jika backend explicitly menolak refresh token (misal status: false)
          if (kDebugMode) {
            debugPrint(
              '[PROACTIVE] Refresh token ditolak server: ${response.data['message']}. Force logout.',
            );
          }
          onUnauthorized?.call();
          return;
        }
      } else if (kDebugMode) {
        debugPrint(
          '[PROACTIVE] Refresh gagal HTTP: ${response.statusCode} ${response.data}',
        );
      }

      _handleProactiveRefreshFailure(accessToken);
    } catch (e) {
      if (kDebugMode) debugPrint('[PROACTIVE ERR] $e');
      if (accessToken != null) {
        _handleProactiveRefreshFailure(accessToken);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Jangan logout jika access token masih valid — coba jadwalkan ulang nanti.
  void _handleProactiveRefreshFailure(String accessToken) {
    if (JwtHelper.isExpired(accessToken)) {
      if (kDebugMode) {
        debugPrint('[PROACTIVE] Access token expired → logout');
      }
      onUnauthorized?.call();
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[PROACTIVE] Refresh gagal, access token masih valid '
        '(${JwtHelper.tokenStatus(accessToken)}) → coba lagi 30 detik kemudian',
      );
    }

    // Beri jeda 30 detik untuk menghindari infinite loop 0 detik saat gagal beruntun
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(seconds: 30), () async {
      await _doProactiveRefresh();
    });
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            debugPrint('[REQ] ${options.method} ${options.uri}');

            debugPrint('[HEADERS]');
            options.headers.forEach((k, v) => debugPrint('$k: $v'));

            if (options.queryParameters.isNotEmpty) {
              debugPrint('[QUERY]');
              debugPrint(options.queryParameters.toString());
            }

            if (options.data != null) {
              debugPrint('[BODY]');
              debugPrint(options.data.toString());
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // if (kDebugMode) debugPrint('[RES] ${response.statusCode} ${response.requestOptions.path}');
          if (kDebugMode) {
            // Ambil message dari response body jika ada, jika tidak gunakan statusMessage bawaan HTTP
            final msg =
                (response.data is Map && response.data['message'] != null)
                ? response.data['message']
                : response.statusMessage;
            debugPrint(
              '[RESPONSE] ${response.data} ${response.statusCode} $msg ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (e, handler) async {
          if (kDebugMode) {
            debugPrint('[ERR] ${e.response?.statusCode} ${e.message}');
          }

          if (e.response?.statusCode == 401) {
            if (!_isRefreshing) {
              if (kDebugMode) {
                debugPrint('[REFRESH] Memulai proses refresh token...');
              }
              _isRefreshing = true;
              try {
                final secureStorage = SecureStorageService();
                final storedRefreshToken = await secureStorage
                    .readRefreshToken();

                if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
                  if (kDebugMode) {
                    debugPrint('[REFRESH] Refresh token kosong, force logout');
                  }
                  onUnauthorized?.call();
                  return handler.next(e);
                }

                final tokenDio = Dio(
                  BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''),
                );

                if (kDebugMode) {
                  debugPrint(
                    '[REFRESH] Hit POST /auth/refresh dengan query parameter',
                  );
                }

                final response = await tokenDio.post(
                  '/auth/refresh',
                  queryParameters: {'refreshToken': storedRefreshToken},
                );

                if (kDebugMode) {
                  debugPrint(
                    '[REFRESH] Response: ${response.statusCode} ${response.data}',
                  );
                }

                if (response.statusCode == 200 &&
                    response.data['status'] == true) {
                  final tokens = AuthTokenHelper.parseFromData(
                    response.data['data'],
                  );

                  if (tokens.accessToken != null) {
                    await AuthTokenHelper.saveTokens(
                      secureStorage,
                      accessToken: tokens.accessToken!,
                      refreshToken: tokens.refreshToken,
                    );
                    setAuthToken(tokens.accessToken!);
                    scheduleProactiveRefresh(tokens.accessToken!);

                    _isRefreshing = false;

                    final opts = e.requestOptions;
                    opts.headers['Authorization'] =
                        'Bearer ${tokens.accessToken}';

                    final cloneReq = await _dio.fetch(opts);
                    return handler.resolve(cloneReq);
                  } else {
                    if (kDebugMode) {
                      debugPrint(
                        '[REFRESH] Gagal memparsing token baru dari response',
                      );
                    }
                  }
                } else {
                  if (kDebugMode) {
                    debugPrint(
                      '[REFRESH] Response refresh tidak sukses (status != true atau statusCode != 200)',
                    );
                  }
                  onUnauthorized?.call();
                }
              } catch (refreshError) {
                if (kDebugMode) {
                  debugPrint('[REFRESH ERR] ${refreshError.toString()}');
                }
                // If refresh fails, redirect to login
                onUnauthorized?.call();
              } finally {
                _isRefreshing = false;
              }
            }
          }

          handler.next(e);
        },
      ),
    );
  }

  void setAuthToken(String token) =>
      _dio.options.headers['Authorization'] = 'Bearer $token';
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    cancelProactiveRefresh();
  }
}
