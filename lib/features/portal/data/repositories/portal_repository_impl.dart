import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/features/portal/data/datasources/portal_data_source.dart';
import 'package:travis/features/portal/domain/entities/user_profile.dart';
import 'package:travis/features/portal/domain/repositories/portal_repository.dart';

class PortalRepositoryImpl implements PortalRepository {
  final PortalDataSource dataSource;

  PortalRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await dataSource.getProfile();
      return right(profile);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to profile';
      return left(ServerFailure(message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
