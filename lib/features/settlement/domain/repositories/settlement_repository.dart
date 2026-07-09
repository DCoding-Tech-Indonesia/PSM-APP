import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_data_source_response.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
import 'package:psm_mobile/core/presentations/entity/core_status_and_message_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_billing.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';

abstract class SettlementRepository {
  Future<Either<Failure, List<CoreScheduleModel>>> fetchTodaySchedule(
    int userId,
  );

  Future<Either<Failure, CoreDataSourceResponse>> checkAllowSettlement(
    int idKoridor,
    int idBus,
    double nextRit,
  );

  Future<Either<Failure, CoreDataSourceResponse>> checkAllowCheckOut(
    int idKoridor,
    int idBus,
    double nextRit,
  );

  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceDocType(
    String keyword,
  );
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceBus(
    String keyword,
    int idKoridor,
  );
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceKoridor(
    String keyword,
  );
  Future<Either<Failure, NextRitaseResponse>> fetchNextRitase(
    int idKoridor,
    int idBus,
  );
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferencePayment(
    String keyword,
  );
  Future<Either<Failure, List<ReferenceDetail>>> fetchReferenceCustType(
    String keyword,
  );
  Future<Either<Failure, List<ReferenceBilling>>> fetchReferenceCustomerBilling(
    int idTypeNasabah,
  );
  Future<Either<Failure, DocumentPreview>> uploadDocument(File file);
  Future<Either<Failure, String>> createSettlement(SettlementCreate request);
  Future<Either<Failure, List<SettlementTaskAuditTrail>>>
  fetchTaskAuditTrailList(String keyword, {int page = 1});
  Future<Either<Failure, SettlementCreate>> fetchTaskAuditTrailDetail(
    int idAuditTrail,
  );
  Future<Either<Failure, CoreStatusAndMessageResponse>> updateSettlement(SettlementCreate request);
  Future<Either<Failure, CoreStatusAndMessageResponse>> submitWorkflow(
    int idAuditTrail,
    String reason,
  );
  Future<Either<Failure, CoreStatusAndMessageResponse>> cancelTaskDraft(int idAuditTrail);
}
