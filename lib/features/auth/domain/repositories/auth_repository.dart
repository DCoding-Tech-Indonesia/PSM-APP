import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
  Future<void> logout();
}