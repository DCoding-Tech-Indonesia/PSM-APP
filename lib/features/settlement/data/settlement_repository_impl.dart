import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_data_source.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_billing.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';
import 'package:psm_mobile/features/settlement/domain/repositories/settlement_repository.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementDataSource dataSource;
  final ReferenceDataSource dataSourceReference;

  SettlementRepositoryImpl({required this.dataSource, required this.dataSourceReference});

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
  Future<Either<Failure, String>> checkAllowSettlement(
      int idKoridor,
      int idBus,
      double nextRit,
      ) async {
    try {
      final result = await dataSource.checkAllowSettlement(
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
  Future<Either<Failure, NextRitaseResponse>> fetchNextRitase(
      int idKoridor,
      int idBus
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
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferencePayment(
    String keyword,
  ) async {
    try {
      final result = await dataSourceReference.fetchReferencePayment(keyword);

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
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceCustType(
    String keyword,
  ) async {
    try {
      final result = await dataSourceReference.fetchReferenceCustType(keyword);

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
  Future<Either<Failure, List<ReferenceBilling>>> fetchReferenceCustomerBilling(
    int idTypeNasabah,
  ) async {
    try {
      final result = await dataSourceReference.fetchReferenceCustomerBilling(
        idTypeNasabah,
      );

      return Right(result);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

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

  @override
  Future<Either<Failure, String>> createSettlement(
    SettlementCreate request,
  ) async {
    try {
      final response = await dataSource.createSettlement(request);

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
  Future<Either<Failure, List<SettlementTaskAuditTrail>>> fetchTaskAuditTrailList(
    String keyword,
  ) async {
    try {
      final result = await dataSource.fetchTaskAuditTrailList(keyword);

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
  Future<Either<Failure, SettlementCreate>> fetchTaskAuditTrailDetail(
    int idAuditTrail,
  ) async {
    try {
      final result = await dataSource.fetchTaskAuditTrailDetail(idAuditTrail);

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
  Future<Either<Failure, String>> updateSettlement(
    SettlementCreate request,
  ) async {
    try {
      final response = await dataSource.updateSettlement(request);

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
  Future<Either<Failure, String>> cancelTaskDraft(int idAuditTrail) async {
    try {
      final response = await dataSource.cancelTaskDraft(idAuditTrail);

      return right(response);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan server';

      return left(ServerFailure(message));
    } catch (_) {
      return left(const ServerFailure('Unexpected error'));
    }
  }
}
