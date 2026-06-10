import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/kmbus/data/kmbus_data_source.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/kmbus/domain/repositories/kmbus_repository.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';

class KmbusRepositoryImpl implements KmbusRepository {
  final KmbusDataSource dataSource;
  final ReferenceDataSource dataSourceReference;

  KmbusRepositoryImpl({
    required this.dataSource,
    required this.dataSourceReference,
  });

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
  Future<Either<Failure, List<ReferenceBus>>> fetchReferenceBus(
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
