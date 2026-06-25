import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_billing.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';

abstract class SettlementRepository {
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(String keyword, int idKoridor);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, double>> fetchNextRitase(int idKoridor, int idBus);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferencePayment(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceCustType(String keyword);
  Future<Either<Failure, List<ReferenceBilling>>> fetchReferenceCustomerBilling(int idTypeNasabah);
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file);
  Future<Either<Failure, String>> createSettlement(SettlementCreate request);
  Future<Either<Failure, List<TaskAuditTrail>>> fetchTaskAuditTrailList(String keyword);
  Future<Either<Failure, SettlementCreate>> fetchTaskAuditTrailDetail(int idAuditTrail);
  Future<Either<Failure, String>> updateSettlement(SettlementCreate request);
  Future<Either<Failure, String>> submitWorkflow(int idAuditTrail, String reason);
  Future<Either<Failure, String>> cancelTaskDraft(int idAuditTrail);
}