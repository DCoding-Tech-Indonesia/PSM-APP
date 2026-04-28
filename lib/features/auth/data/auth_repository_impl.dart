import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/auth/data/auth_data_source.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, LoginResponse>> login(String username,
      String password,) async {
    try {
      final response = await dataSource.login(username, password);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(
        const ServerFailure('Unexpected error'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> logout() async {
    try {
      await dataSource.logout();
      return right("KALUA");
    } on DioException catch (e) {
      return left(ServerFailure("GAGAL"));
    } catch (_) {
      return left(
        const ServerFailure('Unexpected error'),
      );
    }
  }
}