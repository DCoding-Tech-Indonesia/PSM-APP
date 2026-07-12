import 'dart:io';

import 'package:travis/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:travis/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:travis/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:travis/features/reference/domain/entities/document_preview.dart';
import 'package:travis/features/reference/domain/entities/reference_detail.dart';
import 'package:travis/features/timetable/domain/entities/auditTrail/km_task_audit_trail.dart';
import 'package:travis/features/timetable/domain/entities/timetable_checkin.dart';

enum SubmitStatus { idle, submitting, success, failed }

enum SubmitWorkflowStatus { idle, submitting, success, failed }

enum KmbusStatus {
  initial,
  loading,
  success,
  error,
  successSave,
  failedSave,
  fetching,
  onSubmit,
  inValid,
}

enum UploadStatus {
  uploading,
  errorOcr,
  errorDocs,
  successOcr,
  successDocs,
  idling,
}

enum DocumentUploadStatus { idle, uploading, success, failed }

class KmbusState {
  final String disabledCtaMessage;
  final int idDocType;

  final TimetableCheckin? checkinData;

  final bool allowTitikAwal;
  final int? idKm;

  final double? ritaseKe;
  final bool? isLastRitase;
  final bool? isNextRitase;

  final int? idShift;
  final int? idKoridorShift;
  final int? idBusShift;
  final String? noUnit;
  final String? namaKoridor;

  final KmbusStatus status;
  final String? message;
  final String? ocrResult;
  final File? speedometerImage;

  final UploadStatus uploadStatus;
  final DocumentUploadStatus documentUploadStatus;

  final TitikAwalCreate? titikAwalCreate;
  final TitikAkhirCreate? titikAkhirCreate;

  final int idKoridor;
  final List<ReferenceDetail> referenceKoridor;

  final int idBus;
  final List<ReferenceDetail> referenceBus;

  final List<KmbusData> listKmbus;
  final List<KmTaskAuditTrail> listKmbusAuditTrail;

  final int kmbusPage;
  final bool kmbusHasReachedMax;

  final List<DocumentPreview> documentPreview;

  final SubmitStatus submitStatus;
  final SubmitWorkflowStatus submitWorkflowStatus;

  final int idAuditTrail;

  const KmbusState({
    this.disabledCtaMessage = '',

    this.idDocType = 71,

    this.checkinData,

    this.allowTitikAwal = false,
    this.idKm,

    this.ritaseKe,
    this.isLastRitase,
    this.isNextRitase,

    this.idShift,
    this.idKoridorShift,
    this.idBusShift,
    this.noUnit,
    this.namaKoridor,

    this.status = KmbusStatus.initial,
    this.message,
    this.ocrResult,
    this.speedometerImage,

    this.uploadStatus = UploadStatus.idling,
    this.documentUploadStatus = DocumentUploadStatus.idle,

    this.titikAwalCreate,
    this.titikAkhirCreate,

    this.idKoridor = 0,
    this.referenceKoridor = const [],

    this.idBus = 0,
    this.referenceBus = const [],

    this.listKmbus = const [],
    this.listKmbusAuditTrail = const [],

    this.kmbusPage = 1,
    this.kmbusHasReachedMax = false,

    this.documentPreview = const [],

    this.submitStatus = SubmitStatus.idle,
    this.submitWorkflowStatus = SubmitWorkflowStatus.idle,

    this.idAuditTrail = 0,
  });

  KmbusState copyWith({
    String? disabledCtaMessage,

    int? idDocType,

    TimetableCheckin? checkinData,
    bool? allowTitikAwal,
    int? idKm,

    double? ritaseKe,
    bool? isLastRitase,
    bool? isNextRitase,

    int? idShift,
    int? idKoridorShift,
    int? idBusShift,
    String? noUnit,
    String? namaKoridor,

    KmbusStatus? status,
    String? message,
    String? ocrResult,
    File? speedometerImage,

    UploadStatus? uploadStatus,
    DocumentUploadStatus? documentUploadStatus,

    TitikAwalCreate? titikAwalCreate,
    TitikAkhirCreate? titikAkhirCreate,

    int? idKoridor,
    List<ReferenceDetail>? referenceKoridor,

    int? idBus,
    List<ReferenceDetail>? referenceBus,

    List<KmbusData>? listKmbus,
    List<KmTaskAuditTrail>? listKmbusAuditTrail,

    int? kmbusPage,
    bool? kmbusHasReachedMax,

    List<DocumentPreview>? documentPreview,

    SubmitStatus? submitStatus,
    SubmitWorkflowStatus? submitWorkflowStatus,

    int? idAuditTrail,
  }) {
    return KmbusState(
      disabledCtaMessage: disabledCtaMessage ?? this.disabledCtaMessage,

      idDocType: idDocType ?? this.idDocType,

      checkinData: checkinData ?? this.checkinData,

      allowTitikAwal: allowTitikAwal ?? this.allowTitikAwal,
      idKm: idKm ?? this.idKm,

      ritaseKe: ritaseKe ?? this.ritaseKe,
      isLastRitase: isLastRitase ?? this.isLastRitase,
      isNextRitase: isNextRitase ?? this.isNextRitase,

      idShift: idShift ?? this.idShift,
      idKoridorShift: idKoridorShift ?? this.idKoridorShift,
      idBusShift: idBusShift ?? this.idBusShift,
      noUnit: noUnit ?? this.noUnit,
      namaKoridor: namaKoridor ?? this.namaKoridor,

      status: status ?? this.status,
      message: message ?? this.message,
      ocrResult: ocrResult ?? this.ocrResult,
      speedometerImage: speedometerImage ?? this.speedometerImage,

      uploadStatus: uploadStatus ?? this.uploadStatus,
      documentUploadStatus: documentUploadStatus ?? this.documentUploadStatus,

      titikAwalCreate: titikAwalCreate ?? this.titikAwalCreate,
      titikAkhirCreate: titikAkhirCreate ?? this.titikAkhirCreate,

      idKoridor: idKoridor ?? this.idKoridor,
      referenceKoridor: referenceKoridor ?? this.referenceKoridor,

      idBus: idBus ?? this.idBus,
      referenceBus: referenceBus ?? this.referenceBus,

      listKmbus: listKmbus ?? this.listKmbus,
      listKmbusAuditTrail: listKmbusAuditTrail ?? this.listKmbusAuditTrail,

      kmbusPage: kmbusPage ?? this.kmbusPage,
      kmbusHasReachedMax: kmbusHasReachedMax ?? this.kmbusHasReachedMax,

      documentPreview: documentPreview ?? this.documentPreview,

      submitStatus: submitStatus ?? this.submitStatus,
      submitWorkflowStatus: submitWorkflowStatus ?? this.submitWorkflowStatus,

      idAuditTrail: idAuditTrail ?? this.idAuditTrail,
    );
  }
}
