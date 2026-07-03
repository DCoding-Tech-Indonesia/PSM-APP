import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail_input.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';

enum SettlementStatus { initial, loading, success, error, successSave, failedSave, fetching }

class SettlementState extends Equatable {
  final int idDocType;

  final bool jadwalExist;
  final bool? isLastRitase;

  final int? idShift;
  final int? idKoridorShift;
  final int? idBusShift;
  final bool allowInput;

  final List<SettlementTaskAuditTrail> listTaskAuditTrail;

  final int steps;
  final int totalSteps;
  final int activeTabIndex;
  final int activeTabId;
  final String activeTabLabel;

  final bool detailValid;
  final bool allowLastStep;

  final List<ReferenceDetail> referenceBus;
  final List<ReferenceDetail> referenceKoridor;
  final List<ReferenceDetail> referencePayment;
  final List<ReferenceDetail> referenceCustomer;

  final List<String> labelCustomer;
  final String noUnit;
  final String namaKoridor;

  final SettlementStatus status;
  final bool uploadingDoc;

  final String processId;
  final int auditTrailId;
  final int idBus;
  final String code;
  final int idKoridor;
  final double ritase;

  final List<SettlementDetail> detail;
  final List<SettlementDetailInput> detailInput;
  final List<SettlementDocument> document;
  final List<DocumentPreview> documentPreview;

  final String? message;

  const SettlementState({
    this.idDocType = 71,

    this.jadwalExist = true,
    this.isLastRitase,

    this.idShift,
    this.idKoridorShift,
    this.idBusShift,
    this.allowInput = false,

    this.listTaskAuditTrail = const [],

    this.steps = 1,
    this.totalSteps = 1,
    this.activeTabIndex = 1,
    this.activeTabId = 0,
    this.activeTabLabel = '',

    this.detailValid = true,
    this.allowLastStep = false,

    this.referenceBus = const [],
    this.referenceKoridor = const [],
    this.referencePayment = const [],
    this.referenceCustomer = const [],

    this.labelCustomer = const [],
    this.noUnit = '',
    this.namaKoridor = '',

    this.status = SettlementStatus.initial,
    this.uploadingDoc = true,

    this.processId = '',
    this.auditTrailId = 0,
    this.idBus = 0,
    this.code = '',
    this.idKoridor = 0,
    this.ritase = 0,
    this.detail = const [],
    this.detailInput = const [],
    this.document = const [],
    this.documentPreview = const [],
    this.message,
  });

  SettlementState copyWith({
    int? idDocType,

    bool? jadwalExist,
    bool? isLastRitase,

    int? idShift,
    int? idKoridorShift,
    int? idBusShift,
    bool? allowInput,

    List<SettlementTaskAuditTrail>? listTaskAuditTrail,

    int? steps,
    int? totalSteps,
    int? activeTabIndex,
    int? activeTabId,
    String? activeTabLabel,

    bool? detailValid,
    bool? allowLastStep,

    List<ReferenceDetail>? referenceBus,
    List<ReferenceDetail>? referenceKoridor,
    List<ReferenceDetail>? referencePayment,
    List<ReferenceDetail>? referenceCustomer,
    List<ReferenceDetail>? referenceBilling,

    List<String>? labelCustomer,
    String? noUnit,
    String? namaKoridor,

    SettlementStatus? status,
    bool? uploadingDoc,

    String? processId,
    int? auditTrailId,
    int? idBus,
    String? code,
    int? idKoridor,
    double? ritase,
    List<SettlementDetail>? detail,
    List<SettlementDetailInput>? detailInput,
    List<SettlementDocument>? document,
    List<DocumentPreview>? documentPreview,
    String? message,
  }) {
    return SettlementState(
      idDocType: idDocType ?? this.idDocType,

      jadwalExist: jadwalExist ?? this.jadwalExist,
      isLastRitase: isLastRitase ?? this.isLastRitase,

      idShift: idShift ?? this.idShift,
      idKoridorShift: idKoridorShift ?? this.idKoridorShift,
      idBusShift: idBusShift ?? this.idBusShift,
      allowInput: allowInput ?? this.allowInput,

      listTaskAuditTrail: listTaskAuditTrail ?? this.listTaskAuditTrail,

      steps: steps ?? this.steps,
      totalSteps: totalSteps ?? this.totalSteps,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      activeTabId: activeTabId ?? this.activeTabId,
      activeTabLabel: activeTabLabel ?? this.activeTabLabel,

      detailValid: detailValid ?? this.detailValid,
      allowLastStep: allowLastStep ?? this.allowLastStep,

      referenceBus: referenceBus ?? this.referenceBus,
      referenceKoridor: referenceKoridor ?? this.referenceKoridor,
      referencePayment: referencePayment ?? this.referencePayment,
      referenceCustomer: referenceCustomer ?? this.referenceCustomer,

      labelCustomer: labelCustomer ?? this.labelCustomer,
      noUnit: noUnit ?? this.noUnit,
      namaKoridor: namaKoridor ?? this.namaKoridor,

      status: status ?? this.status,
      uploadingDoc: uploadingDoc ?? this.uploadingDoc,

      processId: processId ?? this.processId,
      auditTrailId: auditTrailId ?? this.auditTrailId,
      idBus: idBus ?? this.idBus,
      code: code ?? this.code,
      idKoridor: idKoridor ?? this.idKoridor,
      ritase: ritase ?? this.ritase,
      detail: detail ?? this.detail,
      detailInput: detailInput ?? this.detailInput,
      document: document ?? this.document,
      documentPreview: documentPreview ?? this.documentPreview,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    idDocType,
    jadwalExist,
    isLastRitase,

    listTaskAuditTrail,

    steps,
    totalSteps,
    activeTabIndex,
    activeTabId,
    activeTabLabel,

    detailValid,
    allowLastStep,

    referenceBus,
    referenceKoridor,
    referencePayment,
    referenceCustomer,

    labelCustomer,
    noUnit,
    namaKoridor,
    status,
    processId,
    auditTrailId,
    idBus,
    code,
    idKoridor,
    ritase,
    detail,
    detailInput,
    document,
    documentPreview,
    message,
  ];
}