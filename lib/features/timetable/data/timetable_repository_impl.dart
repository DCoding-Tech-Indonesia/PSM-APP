import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/timetable/data/timetable_data_source.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';
import 'package:psm_mobile/features/timetable/domain/repositories/timetable_repository.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableDataSource dataSource;
  final ReferenceDataSource dataSourceReference;

  TimetableRepositoryImpl({required this.dataSource, required this.dataSourceReference});

  @override
  Future<Either<Failure, List<TimetableData>>> fetchListTimeTable(String keyword) async {
    try {
      final result = await dataSource.fetchTimetableDataList(keyword);

      return right(result);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, double>> fetchNextRitase(
      int idKoridor,
      int idBus
      ) async {
    try {
      final result = await dataSource.fetchNextRitase(idKoridor, idBus);

      return right(result);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, String?>> checkinTimeTable(TimetableCheckin request) async {
    try {
      final response = await dataSource.checkinTimeTable(request);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }




  // region REFERENCE
  @override
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(
      String keyword,
      ) async {
    try {
      final result = await dataSourceReference.fetchReferenceKoridor(keyword);

      return right(result);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(
      String keyword,
      int idKoridor
      ) async {
    try {
      final result = await dataSourceReference.fetchReferenceBus(keyword, idKoridor);

      return right(result);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }
  // endregion
}