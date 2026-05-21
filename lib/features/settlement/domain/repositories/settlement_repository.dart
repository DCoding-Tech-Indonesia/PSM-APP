import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';

abstract class SettlementRepository {
  Future<Either<Failure, List<ReferenceBus>>> fetchReferenceBus(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferencePayment(String keyword);
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceCustType(String keyword);
  Future<Either<Failure, String>> fetchReferenceCustomerBilling(int idTypeNasabah);
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file);
  Future<Either<Failure, String>> createSettlement(SettlementCreate request);
  Future<Either<Failure, List<TaskAuditTrail>>> fetchTaskAuditTrailList(String keyword);
  Future<Either<Failure, SettlementCreate>> fetchTaskAuditTrailDetail(int idAuditTrail);
  Future<Either<Failure, String>> updateSettlement(SettlementCreate request);
  Future<Either<Failure, String>> submitWorkflow(int idAuditTrail, String reason);
}