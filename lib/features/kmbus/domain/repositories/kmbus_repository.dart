import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';

import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_task_audit_trail.dart';

abstract class KmbusRepository {
  Future<Either<Failure, List<CoreScheduleModel>>> fetchTodaySchedule(int userId);

  Future<Either<Failure, List<KmbusData>>> fetchListKmbus(String keyword);
  Future<Either<Failure, List<KmTaskAuditTrail>>> fetchListKmbusAuditTrail(String keyword);
  Future<Either<Failure, double>> fetchNextRitase(int idKoridor, int idBus);

  Future<Either<Failure, String>> createTitikAwal(TitikAwalCreate request);
  Future<Either<Failure, String>> createTitikAkhir(TitikAkhirCreate request);
  Future<Either<Failure, String>> uploadOcr(File file);
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file);

  Future<Either<Failure, bool>> submitTitikAwal(TitikAwalCreate request);
  Future<Either<Failure, String>> submitWorkflow(int idAuditTrail, String reason);

  // FETCHING REFERENCE
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);
}