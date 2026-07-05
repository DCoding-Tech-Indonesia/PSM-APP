import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/datasource/core_data_source.dart';
import 'package:psm_mobile/core/presentations/entity/core_data_source_response.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/timetable/data/timetable_data_source.dart';
import 'package:psm_mobile/features/timetable/domain/entities/response/timetable_checkin_response.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';
import 'package:psm_mobile/features/timetable/domain/repositories/timetable_repository.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableDataSource dataSource;
  final CoreDataSource dataSourceCore;
  final ReferenceDataSource dataSourceReference;

  TimetableRepositoryImpl({
    required this.dataSource,
    required this.dataSourceReference,
    required this.dataSourceCore,
  });

  @override
  Future<Either<Failure, List<TimetableData>>> fetchListTimeTable(
    String keyword,
  ) async {
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
  Future<Either<Failure, List<CoreScheduleModel>>> fetchTodaySchedule(
    int userId,
  ) async {
    try {
      final result = await dataSourceReference.fetchTodaySchedule(
        userId: userId,
      );

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
  Future<Either<Failure, CoreDataSourceResponse>> checkAllowCheckIn(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final result = await dataSourceCore.checkAllowCheckIn(
        idKoridor,
        idBus,
        nextRit,
      );

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
  Future<Either<Failure, CoreDataSourceResponse>> checkAllowCheckOut(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final result = await dataSourceCore.checkAllowCheckOut(
        idKoridor,
        idBus,
        nextRit,
      );

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
  Future<Either<Failure, NextRitaseResponse>> fetchNextRitase(
    int idKoridor,
    int idBus,
  ) async {
    try {
      final result = await dataSourceReference.fetchNextRitase(idKoridor, idBus);

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
  Future<Either<Failure, TimetableCheckinResponse?>> checkinTimeTable(
    TimetableCheckin request,
  ) async {
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

  @override
  Future<Either<Failure, TimetableCheckinResponse?>> checkoutTimeTable(
    TimetableCheckout request,
  ) async {
    try {
      final response = await dataSource.checkoutTimeTable(request);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<KmbusData>>> fetchKmbusDataToday(
      String keyword,
      ) async {
    try {
      final result = await dataSource.fetchKmbusDataToday(keyword);

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
  Future<Either<Failure, CoreDataSourceResponse>> checkAllowTitikAwal(
      int idKoridor,
      int idBus,
      double nextRit,
      ) async {
    try {
      final result = await dataSourceCore.checkAllowTitikAwal(
        idKoridor,
        idBus,
        nextRit,
      );

      return right(result);
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
    int idKoridor,
  ) async {
    try {
      final result = await dataSourceReference.fetchReferenceBus(
        keyword,
        idKoridor,
      );

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
