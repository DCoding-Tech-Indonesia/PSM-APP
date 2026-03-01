import 'package:dio/dio.dart';
import 'package:psm_mobile/core/network/dio_client.dart';

class AuthDataSource {
  final Dio dio;
  AuthDataSource({required this.dio});

  Future<String> login(String email, String password) async {
    final response = await dio.post('/login', data: {'email': email, 'password': password});
    final token = response.data['token'];
    DioClient().setAuthToken(token);
    return token;
  }

  Future<void> logout() async {
    await dio.get('/logout');
    DioClient().clearAuthToken();
  }
}