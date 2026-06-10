import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/helper/auth_token_helper.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';

class AuthDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  AuthDataSource({required this.dio, required this.secureStorageService});

  Future<LoginResponse> login(
    String username,
    String password,
    String fcm,
  ) async {
    try {
      final response = await dio.post(
        '/auth/mobile/login',
        data: {'username': username, 'password': password, 'fcm': fcm},
      );

      if (kDebugMode) {
        print(response);
      }

      final success = response.data["status"];

      if (success == true) {
        final tokens = AuthTokenHelper.parseFromData(response.data['data']);
        final token = tokens.accessToken;
        final userId = response.data["data"][0]["userId"];

        if (token == null) {
          return const LoginResponse(
            isSuccess: false,
            message: 'Token tidak ditemukan dalam response login',
          );
        }

        await AuthTokenHelper.saveTokens(
          secureStorageService,
          accessToken: token,
          refreshToken: tokens.refreshToken ?? token,
        );
        secureStorageService.saveUserId(userId.toString());
        secureStorageService.saveUsername(username);
        DioClient().setAuthToken(token);
        // Mulai timer proaktif: refresh token sebelum expired (5 menit sebelum mati)
        DioClient().scheduleProactiveRefresh(token);

        return const LoginResponse(isSuccess: true, message: "Login berhasil");
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
      await dio.post('/auth/logout', data: {'id': id, 'username': username});
      secureStorageService.clearLogin();
      DioClient().clearAuthToken();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> checkToken() async {
    try {
      final response = await dio.post('/auth/check-token');

      final tokens = AuthTokenHelper.parseFromData(response.data['data']);
      if (tokens.accessToken != null) {
        await AuthTokenHelper.saveTokens(
          secureStorageService,
          accessToken: tokens.accessToken!,
          refreshToken: tokens.refreshToken,
        );
        DioClient().setAuthToken(tokens.accessToken!);
        DioClient().scheduleProactiveRefresh(tokens.accessToken!);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
