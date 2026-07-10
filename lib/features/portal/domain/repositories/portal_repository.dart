import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/portal/domain/entities/user_profile.dart';

abstract class PortalRepository {
  Future<Either<Failure, UserProfile>> getProfile();
}
