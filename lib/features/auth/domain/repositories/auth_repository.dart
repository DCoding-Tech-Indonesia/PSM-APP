import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/auth/domain/entities/login_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(
    String username,
    String password,
    String fcm,
  );
  Future<Either<Failure, String>> logout(String id, String username);
  Future<Either<Failure, String>> checkToken();
}
