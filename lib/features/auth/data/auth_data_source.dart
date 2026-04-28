import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';

class AuthDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  AuthDataSource({
    required this.dio,
    required this.secureStorageService
  });

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/mobile/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final success = response.data["status"];

      if (success == true) {
        final token = response.data["data"][0]["token"];
        final userId = response.data["data"][0]["userId"];
        secureStorageService.saveAccessToken(token);
        secureStorageService.saveUserId(userId.toString());
        secureStorageService.saveUsername(username);
        DioClient().setAuthToken(token);

        return const LoginResponse(
          isSuccess: true,
          message: "Login berhasil",
        );
      }

      return LoginResponse(
        isSuccess: false,
        message: response.data["message"] ?? "Login gagal",
      );
    } catch (e) {
      return LoginResponse(
        isSuccess: false,
        message: "Terjadi kesalahan: ${e.toString()}",
      );
    }
  }

  Future<void> logout(String id, String username) async {
    try {
      final response = await dio.post(
        '/auth/logout',
        data: {
          'id': id,
          'username': username,
        },
      );
      print("RESPONSE LOGOUT");
      print(response);
      secureStorageService.clearLogin();
      DioClient().clearAuthToken();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> checkToken() async {
    try {
      final response = await dio.post(
          '/auth/check-token'
      );

      final token = response.data["data"][0]["token"];
      DioClient().setAuthToken(token);
      secureStorageService.saveAccessToken(token);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}