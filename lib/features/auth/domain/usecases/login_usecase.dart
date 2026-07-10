import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/auth/domain/entities/login_response.dart';
import 'package:travis/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  Future<Either<Failure, LoginResponse>> call(
    String username,
    String password,
    String fcm,
  ) {
    return authRepository.login(username, password, fcm);
  }
}
