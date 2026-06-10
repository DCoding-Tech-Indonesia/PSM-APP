import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/auth/domain/entities/login_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(
    String username,
    String password,
    String fcm,
  );
  Future<Either<Failure, String>> logout(String id, String username);
  Future<Either<Failure, String>> checkToken();
}
