import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/kmbus/data/kmbus_data_source.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/kmbus/domain/repositories/kmbus_repository.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_task_audit_trail.dart';

class KmbusRepositoryImpl implements KmbusRepository {
  final KmbusDataSource dataSource;
  final ReferenceDataSource dataSourceReference;

  KmbusRepositoryImpl({
    required this.dataSource,
    required this.dataSourceReference,
  });

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
  Future<Either<Failure, String>> checkAllowTitikAwal(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final result = await dataSource.checkAllowTitikAwal(
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
  Future<Either<Failure, String>> checkAllowTitikAkhir(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final result = await dataSource.checkAllowTitikAkhir(
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
  Future<Either<Failure, TitikAwalCreate>> fetchDetailAuditTrailAwal(
    int idAuditTrail,
  ) async {
    try {
      final result = await dataSource.fetchDetailAuditTrailAwal(idAuditTrail);

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
  Future<Either<Failure, TitikAkhirCreate>> fetchDetailAuditTrailAkhir(
    int idAuditTrail,
  ) async {
    try {
      final result = await dataSource.fetchDetailAuditTrailAkhir(idAuditTrail);

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
  Future<Either<Failure, List<KmbusData>>> fetchListKmbus(
    String keyword,
  ) async {
    try {
      final result = await dataSource.fetchKmbusData(keyword);

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
  Future<Either<Failure, List<KmTaskAuditTrail>>> fetchListKmbusAuditTrail(
    String keyword,
  ) async {
    try {
      final result = await dataSource.fetchKmbusDataListAuditTrail(keyword);

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
  Future<Either<Failure, String>> createTitikAwal(
    TitikAwalCreate request,
  ) async {
    try {
      final response = await dataSource.createTitikAwal(request);

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
  Future<Either<Failure, String>> createTitikAkhir(
    TitikAkhirCreate request,
  ) async {
    try {
      final response = await dataSource.createTitikAkhir(request);

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
  Future<Either<Failure, String>> updateTitikAwal(
      TitikAwalCreate request, int idAuditTrail
      ) async {
    try {
      final response = await dataSource.updateTitikAwal(request, idAuditTrail);

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
  Future<Either<Failure, String>> updateTitikAkhir(
      TitikAkhirCreate request, int idAuditTrail
      ) async {
    try {
      final response = await dataSource.updateTitikAkhir(request, idAuditTrail);

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
  Future<Either<Failure, String>> submitWorkflow(
    int idAuditTrail,
    String reason,
  ) async {
    try {
      final response = await dataSource.submitWorkflow(idAuditTrail, reason);

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
  Future<Either<Failure, String>> uploadOcr(File file) async {
    try {
      final response = await dataSource.uploadOcr(file);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          e.response?.data?.toString() ??
          'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file) async {
    try {
      final response = await dataSourceReference.uploadDocument(file);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }

  // FETCHING REFERENCE
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
}
