import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/auth/data/auth_data_source.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, LoginResponse>> login(
    String username,
    String password,
    String fcm,
  ) async {
    try {
      final response = await dataSource.login(username, password, fcm);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, String>> logout(String id, String username) async {
    try {
      await dataSource.logout(id, username);
      return right("KALUA");
    } on DioException catch (_) {
      return left(ServerFailure("GAGAL"));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, String>> checkToken() async {
    try {
      await dataSource.checkToken();
      return right("CHECK");
    } on DioException catch (_) {
      return left(ServerFailure("GAGAL"));
    } catch (_) {
      return Left(const ServerFailure('Unexpected error'));
    }
  }
}
