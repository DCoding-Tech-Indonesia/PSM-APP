import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/portal/domain/entities/user_profile.dart';

abstract class PortalRepository {
  Future<Either<Failure, UserProfile>> getProfile();
}
