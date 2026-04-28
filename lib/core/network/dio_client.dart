import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  DioClient._internal();
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;
  Dio get instance => _dio;

  void init({String? baseUrl, String? token}) {
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
      onError: (e, handler) {
        if (kDebugMode) debugPrint('[ERR] ${e.response?.statusCode} ${e.message}');
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String token) => _dio.options.headers['Authorization'] = 'Bearer $token';
  void clearAuthToken() => _dio.options.headers.remove('Authorization');
}