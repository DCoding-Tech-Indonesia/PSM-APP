import 'dart:io';

import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';

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

class KmbusState {
  final KmbusStatus status;
  final String? message;
  final String? ocrResult;
  final File? speedometerImage;
  final UploadStatus uploadStatus;
  final TitikAwalCreate? titikAwalCreate;

  final int idKoridor;
  final List<ReferenceDetail> referenceKoridor;
  final int idBus;
  final List<ReferenceDetail> referenceBus;

  final List<KmbusData> listKmbus;


  const KmbusState({
    this.status = KmbusStatus.initial,
    this.message,
    this.ocrResult,
    this.speedometerImage,
    this.uploadStatus = UploadStatus.idling,
    this.titikAwalCreate,

    this.idKoridor = 0,
    this.referenceKoridor = const [],
    this.idBus = 0,
    this.referenceBus = const [],

    this.listKmbus = const [],
  });

  KmbusState copyWith({
    KmbusStatus? status,
    String? message,
    String? ocrResult,
    File? speedometerImage,
    UploadStatus? uploadStatus,
    TitikAwalCreate? titikAwalCreate,

    int? idKoridor,
    List<ReferenceDetail>? referenceKoridor,
    int? idBus,
    List<ReferenceDetail>? referenceBus,

    List<KmbusData>? listKmbus,
  }) {
    return KmbusState(
      status: status ?? this.status,
      message: message,
      ocrResult: ocrResult ?? this.ocrResult,
      speedometerImage: speedometerImage ?? this.speedometerImage,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      titikAwalCreate: titikAwalCreate ?? this.titikAwalCreate,

      idKoridor: idKoridor ?? this.idKoridor,
      referenceKoridor: referenceKoridor ?? this.referenceKoridor,
      idBus: idBus ?? this.idBus,
      referenceBus: referenceBus ?? this.referenceBus,

      listKmbus: listKmbus ?? this.listKmbus,
    );
  }
}