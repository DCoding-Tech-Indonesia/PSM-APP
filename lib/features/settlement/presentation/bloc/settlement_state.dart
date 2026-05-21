import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail_input.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';

enum SettlementStatus { initial, loading, success, error, successSave, failedSave }

class SettlementState extends Equatable {
  final List<TaskAuditTrail> listTaskAuditTrail;

  final int steps;
  final int totalSteps;
  final List<ReferenceBus> referenceBus;
  final List<ReferenceDetail> referenceKoridor;
  final List<String> labelPayment;
  final List<String> labelCustomer;
  final String noUnit;
  final String namaKoridor;

  final SettlementStatus status;

  final String processId;
  final int auditTrailId;
  final int idBus;
  final String code;
  final int idKoridor;
  final int idShift;

  final List<SettlementDetail> detail;
  final List<SettlementDetailInput> detailInput;
  final List<SettlementDocument> document;
  final List<DocumentPreview> documentPreview;

  final String? message;

  const SettlementState({
    this.listTaskAuditTrail = const [],

    this.steps = 1,
    this.totalSteps = 1,
    this.referenceBus = const [],
    this.referenceKoridor = const [],
    this.labelPayment = const [],
    this.labelCustomer = const [],
    this.noUnit = '',
    this.namaKoridor = '',
    this.status = SettlementStatus.initial,
    this.processId = '',
    this.auditTrailId = 0,
    this.idBus = 0,
    this.code = '',
    this.idKoridor = 0,
    this.idShift = 0,
    this.detail = const [],
    this.detailInput = const [],
    this.document = const [],
    this.documentPreview = const [],
    this.message,
  });

  SettlementState copyWith({
    List<TaskAuditTrail>? listTaskAuditTrail,

    int? steps,
    int? totalSteps,
    List<ReferenceBus>? referenceBus,
    List<ReferenceDetail>? referenceKoridor,
    List<String>? labelPayment,
    List<String>? labelCustomer,
    String? noUnit,
    String? namaKoridor,
    SettlementStatus? status,
    String? processId,
    int? auditTrailId,
    int? idBus,
    String? code,
    int? idKoridor,
    int? idShift,
    List<SettlementDetail>? detail,
    List<SettlementDetailInput>? detailInput,
    List<SettlementDocument>? document,
    List<DocumentPreview>? documentPreview,
    String? message,
  }) {
    return SettlementState(
      listTaskAuditTrail: listTaskAuditTrail ?? this.listTaskAuditTrail,

      steps: steps ?? this.steps,
      totalSteps: totalSteps ?? this.totalSteps,
      referenceBus: referenceBus ?? this.referenceBus,
      referenceKoridor: referenceKoridor ?? this.referenceKoridor,
      labelPayment: labelPayment ?? this.labelPayment,
      labelCustomer: labelCustomer ?? this.labelCustomer,
      noUnit: noUnit ?? this.noUnit,
      namaKoridor: namaKoridor ?? this.namaKoridor,
      status: status ?? this.status,
      processId: processId ?? this.processId,
      auditTrailId: auditTrailId ?? this.auditTrailId,
      idBus: idBus ?? this.idBus,
      code: code ?? this.code,
      idKoridor: idKoridor ?? this.idKoridor,
      idShift: idShift ?? this.idShift,
      detail: detail ?? this.detail,
      detailInput: detailInput ?? this.detailInput,
      document: document ?? this.document,
      documentPreview: documentPreview ?? this.documentPreview,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    listTaskAuditTrail,

    steps,
    totalSteps,
    referenceBus,
    referenceKoridor,
    labelPayment,
    labelCustomer,
    noUnit,
    namaKoridor,
    status,
    processId,
    auditTrailId,
    idBus,
    code,
    idKoridor,
    idShift,
    detail,
    detailInput,
    document,
    documentPreview,
    message,
  ];
}