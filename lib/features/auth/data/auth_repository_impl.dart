import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/auth/data/auth_data_source.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, String>> login(
      String username,
      String password,
      ) async {
    try {
      final token = await dataSource.login(username, password);

      return right(token);
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
  Future<void> logout() async {
    try {
      // await remoteDataSource.logout();
    } catch (_) {
    }
  }
}