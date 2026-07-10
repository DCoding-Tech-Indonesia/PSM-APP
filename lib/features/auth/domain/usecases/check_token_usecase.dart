import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/auth/domain/repositories/auth_repository.dart';

class CheckTokenUseCase {
  final AuthRepository authRepository;

  const CheckTokenUseCase(this.authRepository);

  Future<Either<Failure, String>> call() {
    return authRepository.checkToken();
  }
}
