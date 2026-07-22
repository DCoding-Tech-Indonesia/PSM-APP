import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travis/core/helper/auth_token_helper.dart';
import 'package:travis/core/helper/error_helper_parser.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/features/auth/domain/entities/login_response.dart';

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
        final userRoleId = response.data["data"][0]["userRoleId"];
        final firstLogin = response.data["data"][0]["firstLogin"] ?? false;
        final pramugaraId = response.data["data"][0]["pramugaraId"];
        final korlapId = response.data["data"][0]["korlapId"];
        final pegawaiId = response.data["data"][0]["pegawaiId"];

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
        secureStorageService.saveUserRoleIdId(userRoleId.toString());
        secureStorageService.saveUsername(username);
        secureStorageService.saveFirstLogin(firstLogin);
        if (pramugaraId != null) {
          secureStorageService.savePramugaraId(pramugaraId.toString());
        }
        if (korlapId != null) {
          secureStorageService.saveKorlapId(korlapId.toString());
        }
        if (pegawaiId != null) {
          secureStorageService.savePegawaiId(pegawaiId.toString());
        }
        DioClient().setAuthToken(token);
        // Mulai timer proaktif: refresh token sebelum expired (5 menit sebelum mati)\r
        DioClient().scheduleProactiveRefresh(token);

        return LoginResponse(
          isSuccess: true,
          message: firstLogin
              ? "Silakan atur password baru Anda"
              : "Login berhasil",
          firstLogin: firstLogin,
        );
      }

      return LoginResponse(
        isSuccess: false,
        message: response.data["message"] ?? "Login gagal",
      );
    } catch (e) {
      final cleanMessage = ErrorParserHelper.parse(e.toString());

      return LoginResponse(isSuccess: false, message: cleanMessage);
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
