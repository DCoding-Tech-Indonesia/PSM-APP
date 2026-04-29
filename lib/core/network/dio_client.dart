import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

    _dio = Dio(BaseOptions(
      baseUrl: resolvedBaseUrl,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    _addInterceptors();
  }

  bool _isRefreshing = false;

  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
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

          handler.next(options);
        }
      },
      onResponse: (response, handler) {
        if (kDebugMode) debugPrint('[RES] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (e, handler) async {
        if (kDebugMode) debugPrint('[ERR] ${e.response?.statusCode} ${e.message}');

        if (e.response?.statusCode == 401) {
          if (!_isRefreshing) {
            if (kDebugMode) debugPrint('[REFRESH] Memulai proses refresh token...');
            _isRefreshing = true;
            try {
              final tokenDio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL'] ?? ''));
              
              // Depending on the backend API, some require the old token in header, others require refresh_token in body.
              // Here we try to pass the expired token in the header just in case.
              final authHeader = _dio.options.headers['Authorization'];
              if (authHeader != null) {
                tokenDio.options.headers['Authorization'] = authHeader;
              }

              // Panggil endpoint refresh tanpa query parameter refreshToken
              if (kDebugMode) debugPrint('[REFRESH] Hit POST /auth/refresh');
              final response = await tokenDio.post('/auth/refresh');
              if (kDebugMode) debugPrint('[REFRESH] Response: ${response.statusCode} ${response.data}');
              
              if (response.statusCode == 200 && response.data['status'] == true) {
                // Parse the new token based on backend structure
                // Assuming it's the exact same structure as login: response.data["data"][0]["token"]
                // Adjust if the refresh response is different.
                final dynamic newData = response.data['data'];
                String? newToken;
                
                if (newData is List && newData.isNotEmpty && newData[0]['token'] != null) {
                   newToken = newData[0]['token'];
                } else if (newData is Map && newData['token'] != null) {
                   newToken = newData['token'];
                }
                
                if (newToken != null) {
                  // Save the new token
                  final secureStorage = SecureStorageService();
                  await secureStorage.saveAccessToken(newToken);
                  setAuthToken(newToken);
                  
                  _isRefreshing = false;
                  
                  // Retry the original request with the new token
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newToken';
                  
                  final cloneReq = await _dio.fetch(opts);
                  return handler.resolve(cloneReq);
                } else {
                  if (kDebugMode) debugPrint('[REFRESH] Gagal memparsing token baru dari response');
                }
              } else {
                if (kDebugMode) debugPrint('[REFRESH] Response refresh tidak sukses (status != true atau statusCode != 200)');
                onUnauthorized?.call();
              }
            } catch (refreshError) {
              if (kDebugMode) debugPrint('[REFRESH ERR] ${refreshError.toString()}');
              // If refresh fails, redirect to login
              onUnauthorized?.call();
            } finally {
              _isRefreshing = false;
            }
          }
        }

        handler.next(e);
      },
    ));
  }

  void setAuthToken(String token) => _dio.options.headers['Authorization'] = 'Bearer $token';
  void clearAuthToken() => _dio.options.headers.remove('Authorization');
}