import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  const LogoutUseCase(this.authRepository);

  Future<Either<Failure, String>> call(String id, String username) {
    return authRepository.logout(id, username);
  }
}
