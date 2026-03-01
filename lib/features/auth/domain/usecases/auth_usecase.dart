import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  const LoginUseCase(this.authRepository);

  Future<Either<Failure, String>> call(String email, String password) {
    return authRepository.login(email, password);
  }
}