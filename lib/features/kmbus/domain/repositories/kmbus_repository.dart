import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';

abstract class KmbusRepository {
  Future<Either<Failure, String>> createTitikAwal(TitikAwalCreate request);
  Future<Either<Failure, String>> uploadOcr(File file);
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file);

  // FETCHING REFERENCE
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);
}