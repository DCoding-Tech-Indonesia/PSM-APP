import 'package:dio/dio.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';

class AuthDataSource {
  final Dio dio;
  AuthDataSource({required this.dio});

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/mobile/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      print('[RESPONSE]');
      print(response);

      final success = response.data["status"];

      if (success == true) {
        final token = response.data["data"][0]["token"];
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

  Future<void> logout() async {
    final response = await dio.post('/auth/logout');
    print("RESPONSE LOGOUT");
    print(response);
    DioClient().clearAuthToken();
  }
}