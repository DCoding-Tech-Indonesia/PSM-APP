import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_document.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/kmbus/domain/repositories/kmbus_repository.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_event.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';
import 'package:psm_mobile/features/reference/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';

class KmbusBloc extends Bloc<KmbusEvent, KmbusState> {
  final KmbusRepository kmbusRepository;
  final SecureStorageService secureStorageService;

  KmbusBloc(this.kmbusRepository, this.secureStorageService)
    : super(const KmbusState()) {
    on<PageDashboardLoad>((event, emit) async {
      emit(
        state.copyWith(
          status: KmbusStatus.initial,
          submitStatus: SubmitStatus.idle,
          submitWorkflowStatus: SubmitWorkflowStatus.idle,
        ),
      );

      try {
        final listMaster = await kmbusRepository.fetchKmbusDataToday('');
        final listAuditTrail = await kmbusRepository.fetchListKmbusAuditTrail('');

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(
              status: KmbusStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        final kmBusListAuditTrail = listAuditTrail.fold((failure) {
          emit(
            state.copyWith(
              status: KmbusStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (kmBusListAuditTrail == null) return;

        final activeMasterData = kmBusListMaster
            ?.cast<KmbusData?>()
            .firstWhere(
              (e) => e != null && e.titikAkhir == null,
          orElse: () => null,
        );

        final idKm = activeMasterData?.id ?? 0;

        emit(
          state.copyWith(
            listKmbusAuditTrail: kmBusListAuditTrail,
            idKm: idKm,
          ),
        );

        final bool hasDraftTitikAwal = kmBusListAuditTrail.any((data) {
          final bool isTitikAwal =
              data.dataAfter.titikAwal != null &&
                  data.dataAfter.titikAwal != 0;

          final bool isDraft = data.status.code == "DFT";

          return isTitikAwal && isDraft;
        });

        final userIdString = await secureStorageService.readUserId();
        final userId = int.tryParse(userIdString ?? '') ?? 0;

        final todaySchedule =
        await kmbusRepository.fetchTodaySchedule(userId);

        final todayScheduleData = todaySchedule.fold((failure) {
          emit(
            state.copyWith(
              status: KmbusStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (todayScheduleData == null || todayScheduleData.isEmpty) {
          emit(
            state.copyWith(
              status: KmbusStatus.error,
              message: "Jadwal tidak ditemukan",
            ),
          );
          return;
        }

        final idKoridorShift = todayScheduleData[0].lokasi.koridor;
        final idBusShift = todayScheduleData[0].bus.id;

        final nextRitaseResult = await kmbusRepository.fetchNextRitase(
          idKoridorShift,
          idBusShift!,
        );

        final double ritaseValue = nextRitaseResult.fold(
              (_) => 0.0,
              (value) => value.ritaseKe!,
        );

        final checkAwalFuture = kmbusRepository.checkAllowTitikAwal(
          idKoridorShift,
          idBusShift,
          ritaseValue,
        );

        final results = await Future.wait([checkAwalFuture]);

        final checkAwalResult = results[0];

        final bool isAllowTitikAwal = checkAwalResult.fold(
              (_) => false,
              (res) =>
          res == "Access Granted" &&
              !hasDraftTitikAwal,
        );

        emit(
          state.copyWith(
            allowTitikAwal: isAllowTitikAwal,
            idShift: todayScheduleData[0].shift.id,
            idKoridorShift: idKoridorShift,
            idBusShift: idBusShift,
            status: KmbusStatus.success,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(
          state.copyWith(
            status: KmbusStatus.error,
            message: e.toString(),
          ),
        );
      }
    });

    on<PageHistoryLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.initial));

      try {
        final listMaster = await kmbusRepository.fetchListKmbus('');

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        kmBusListMaster?.sort((a, b) {
          final dateA =
          a.tanggalKm != null ? DateTime.tryParse(a.tanggalKm!) : DateTime(1970);
          final dateB =
          b.tanggalKm != null ? DateTime.tryParse(b.tanggalKm!) : DateTime(1970);

          return dateB!.compareTo(dateA!);
        });

        emit(
          state.copyWith(
            status: KmbusStatus.success,
            listKmbus: kmBusListMaster,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<KmbusTitikAwalInputLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.loading));

      try {
        final userRoleIdString = await secureStorageService.readUserRoleId();
        final userRoleId = int.tryParse(userRoleIdString ?? '') ?? 0;

        final resultKoridor = await kmbusRepository.fetchReferenceKoridor('');

        final koridorList = resultKoridor.fold<List<ReferenceDetail>?>(
              (failure) {
            emit(
              state.copyWith(
                status: KmbusStatus.error,
                message: failure.message,
              ),
            );
            return null;
          },
              (data) => data,
        );

        if (event.idAuditTrail != null) {
          final result = await kmbusRepository.fetchDetailAuditTrailAwal(
            event.idAuditTrail!,
          );

          await result.fold(
                (failure) async {
              emit(
                state.copyWith(
                  status: KmbusStatus.error,
                  message: failure.message,
                ),
              );
            },
                (titikAwalData) async {
              final resultBus = await kmbusRepository.fetchReferenceBus(
                '',
                titikAwalData.idKoridor,
              );

              final busList = resultBus.fold<List<ReferenceDetail>?>(
                    (failure) {
                  emit(
                    state.copyWith(
                      status: KmbusStatus.error,
                      message: failure.message,
                    ),
                  );
                  return null;
                },
                    (data) => data,
              );

              emit(
                state.copyWith(
                  status: KmbusStatus.success,

                  idShift: titikAwalData.idShift,
                  idKoridor: titikAwalData.idKoridor,
                  idBus: titikAwalData.idBus,

                  referenceKoridor: koridorList,
                  referenceBus: busList,

                  titikAwalCreate: titikAwalData,

                  ocrResult: titikAwalData.titikAwal.toString(),

                  documentPreview: titikAwalData.document
                      .map(
                        (e) => DocumentPreview(
                      idDocument: e.idDocument,
                      url: e.urlDoc!,
                    ),
                  )
                      .toList(),
                ),
              );
            },
          );

          return;
        }

        final resultBus = await kmbusRepository.fetchReferenceBus(
          '',
          event.idKoridorShift,
        );

        final busList = resultBus.fold<List<ReferenceDetail>?>(
              (failure) {
            emit(
              state.copyWith(
                status: KmbusStatus.error,
                message: failure.message,
              ),
            );
            return null;
          },
              (data) => data,
        );

        final nextRitase = await kmbusRepository.fetchNextRitase(
          event.idKoridorShift,
          event.idBusShift,
        );

        final ritaseValue = nextRitase.fold<double>(
              (_) => 0.0,
              (value) => value.ritaseKe ?? 0.0,
        );

        final tanggal = DateTime.now().toIso8601String().split('T')[0];

        final checkin = TimetableCheckin(
          tanggal: tanggal,
          idKoridor: event.idKoridorShift,
          idBus: event.idBusShift,
          idShift: event.idShift,
          idPramugara: userRoleId,
          ritaseKe: ritaseValue,
          long: 0.0,
          lat: 0.0,
        );

        final initial = _initialTitikAwalCreate.copyWith(
          idPramugara: userRoleId,
          idShift: event.idShift,
          idKoridor: event.idKoridorShift,
          idBus: event.idBusShift,
          ritaseKe: ritaseValue,
          tanggalKm: tanggal,
        );

        emit(
          state.copyWith(
            status: KmbusStatus.success,

            checkinData: checkin,

            idShift: event.idShift,
            idKoridor: event.idKoridorShift,
            idBus: event.idBusShift,

            referenceKoridor: koridorList,
            referenceBus: busList,

            titikAwalCreate: initial,

            documentPreview: const [],
            ocrResult: null,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(
          state.copyWith(
            status: KmbusStatus.error,
            message: e.toString(),
          ),
        );
      }
    });

    on<KmbusTitikAkhirInputLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.initial));

      try {
        final initial = _initialTitikAkhirCreate.copyWith(
          idKm: event.idKm,
          auditTrailId: event.idAuditTrail,
        );

        if (event.idAuditTrail != null) {
          final result = await kmbusRepository.fetchDetailAuditTrailAkhir(
            event.idAuditTrail!,
          );

          result.fold(
            (failure) {
              emit(
                state.copyWith(
                  status: KmbusStatus.error,
                  message: failure.message,
                ),
              );
            },
            (titikAkhirData) {
              print(titikAkhirData);
              emit(
                state.copyWith(
                  status: KmbusStatus.success,
                  titikAkhirCreate: titikAkhirData.copyWith(idKm: event.idKm),
                  ocrResult: titikAkhirData.titikAkhir.toString(),
                ),
              );
            },
          );
        }
        else {
          emit(
            state.copyWith(
              status: KmbusStatus.success,
              titikAkhirCreate: initial,
            ),
          );
        }
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<UploadOcrAwalEvent>((event, emit) async {
      emit(
        state.copyWith(
          uploadStatus: UploadStatus.uploading,
          documentUploadStatus: DocumentUploadStatus.uploading,
        ),
      );

      final result = await kmbusRepository.uploadOcr(event.file);

      await result.fold(
        (failure) async {
          emit(
            state.copyWith(
              uploadStatus: UploadStatus.errorOcr,
              documentUploadStatus: DocumentUploadStatus.failed,
              message: failure.message,
              ocrResult: "-",
            ),
          );
        },
        (ocrValue) async {
          if (ocrValue.isEmpty) {
            emit(
              state.copyWith(
                uploadStatus: UploadStatus.errorOcr,
                documentUploadStatus: DocumentUploadStatus.failed,
                message: "Gagal OCR",
                ocrResult: "-",
              ),
            );
            return;
          }

          final km = int.tryParse(ocrValue);
          if (km == null) {
            emit(
              state.copyWith(
                uploadStatus: UploadStatus.errorOcr,
                documentUploadStatus: DocumentUploadStatus.failed,
                message: "OCR invalid",
                ocrResult: "-",
              ),
            );
            return;
          }

          final create = state.titikAwalCreate ?? _initialTitikAwalCreate;

          final uploadDoc = await kmbusRepository.uploadDocument(event.file);

          uploadDoc.fold(
            (failure) {
              emit(
                state.copyWith(
                  uploadStatus: UploadStatus.errorDocs,
                  documentUploadStatus: DocumentUploadStatus.failed,
                  message: failure.message,
                ),
              );
            },
            (data) {
              final newDocument = KmbusDocument(
                idKmDocument: data.idDocument,
                idDocument: data.idDocument,
                idDocumentType: 72,
              );

              final newPreview = DocumentPreview(
                idDocument: data.idDocument,
                url: data.url,
              );

              emit(
                state.copyWith(
                  uploadStatus: UploadStatus.successDocs,
                  documentUploadStatus: DocumentUploadStatus.success,
                  ocrResult: ocrValue,
                  speedometerImage: event.file,

                  titikAwalCreate: create.copyWith(
                    titikAwal: km,
                    document: [...create.document, newDocument],
                  ),

                  documentPreview: [...state.documentPreview, newPreview],
                ),
              );
            },
          );
        },
      );
    });

    on<UploadOcrAkhirEvent>((event, emit) async {
      emit(
        state.copyWith(
          uploadStatus: UploadStatus.uploading,
          documentUploadStatus: DocumentUploadStatus.uploading,
        ),
      );

      final result = await kmbusRepository.uploadOcr(event.file);

      await result.fold(
        (failure) async {
          emit(
            state.copyWith(
              uploadStatus: UploadStatus.errorOcr,
              documentUploadStatus: DocumentUploadStatus.failed,
              message: failure.message,
              ocrResult: "-",
            ),
          );
        },
        (ocrValue) async {
          if (ocrValue.isEmpty) {
            emit(
              state.copyWith(
                uploadStatus: UploadStatus.errorOcr,
                documentUploadStatus: DocumentUploadStatus.failed,
                message: "Gagal OCR",
                ocrResult: "-",
              ),
            );
            return;
          }

          final km = int.tryParse(ocrValue);
          if (km == null) {
            emit(
              state.copyWith(
                uploadStatus: UploadStatus.errorOcr,
                documentUploadStatus: DocumentUploadStatus.failed,
                message: "OCR invalid",
                ocrResult: "-",
              ),
            );
            return;
          }

          final create = state.titikAkhirCreate ?? _initialTitikAkhirCreate;

          final uploadDoc = await kmbusRepository.uploadDocument(event.file);

          uploadDoc.fold(
            (failure) {
              emit(
                state.copyWith(
                  uploadStatus: UploadStatus.errorDocs,
                  documentUploadStatus: DocumentUploadStatus.failed,
                  message: failure.message,
                ),
              );
            },
            (data) {
              final newDocument = KmbusDocument(
                idKmDocument: data.idDocument,
                idDocument: data.idDocument,
                idDocumentType: 72,
              );

              final newPreview = DocumentPreview(
                idDocument: data.idDocument,
                url: data.url,
              );

              emit(
                state.copyWith(
                  uploadStatus: UploadStatus.successDocs,
                  documentUploadStatus: DocumentUploadStatus.success,
                  ocrResult: ocrValue,
                  speedometerImage: event.file,

                  titikAkhirCreate: create.copyWith(
                    titikAkhir: km,
                    document: [...create.document, newDocument],
                  ),

                  documentPreview: [...state.documentPreview, newPreview],
                ),
              );
            },
          );
        },
      );
    });

    on<RemoveDocumentById>((event, emit) {
      final updatedPreview = state.documentPreview
          .where((e) => e.idDocument != event.idDocument)
          .toList();

      final updatedDocsAwal = (state.titikAwalCreate?.document ?? [])
          .where((e) => e.idDocument != event.idDocument)
          .toList();

      final updatedDocsAkhir = (state.titikAkhirCreate?.document ?? [])
          .where((e) => e.idDocument != event.idDocument)
          .toList();

      emit(
        state.copyWith(
          documentPreview: updatedPreview,

          titikAwalCreate: state.titikAwalCreate?.copyWith(
            document: updatedDocsAwal,
          ),

          titikAkhirCreate: state.titikAkhirCreate?.copyWith(
            document: updatedDocsAkhir,
          ),

          ocrResult: updatedPreview.isEmpty &&
              updatedDocsAwal.isEmpty &&
              updatedDocsAkhir.isEmpty
              ? null
              : state.ocrResult,
        ),
      );
    });

    on<EditOdometerAwal>((event, emit) async {
      emit(
        state.copyWith(
          ocrResult: event.odometerVal.toString(),
          titikAwalCreate: state.titikAwalCreate?.copyWith(
            titikAwal: event.odometerVal,
          ),
        ),
      );
    });

    on<EditOdometerAkhir>((event, emit) async {
      emit(
        state.copyWith(
          ocrResult: event.odometerVal.toString(),
          titikAkhirCreate: state.titikAkhirCreate?.copyWith(
            titikAkhir: event.odometerVal,
          ),
        ),
      );
    });

    on<SubmitTitikAwal>((event, emit) async {
      emit(state.copyWith(submitStatus: SubmitStatus.submitting));

      final result = await kmbusRepository.createTitikAwal(
        state.titikAwalCreate!,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              submitStatus: SubmitStatus.failed,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              submitStatus: SubmitStatus.success,
              idAuditTrail: int.parse(data),
            ),
          );
        },
      );
    });

    on<SubmitTitikAkhir>((event, emit) async {
      emit(state.copyWith(submitStatus: SubmitStatus.submitting));

      var result;

      if (event.idAuditTrail != null) {
        result = await kmbusRepository.updateTitikAkhir(
          state.titikAkhirCreate!,
          event.idAuditTrail!,
        );
      } else {
        result = await kmbusRepository.createTitikAkhir(
          state.titikAkhirCreate!,
        );
      }

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              submitStatus: SubmitStatus.failed,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              submitStatus: SubmitStatus.success,
              idAuditTrail: event.idAuditTrail ?? int.parse(data),
            ),
          );
        },
      );
    });

    on<SubmitWorkflow>((event, emit) async {
      emit(
        state.copyWith(
          submitStatus: SubmitStatus.idle,
          submitWorkflowStatus: SubmitWorkflowStatus.submitting,
        ),
      );

      final result = await kmbusRepository.submitWorkflow(
        event.idAuditTrail,
        event.reason != '' ? event.reason : 'Done',
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              submitWorkflowStatus: SubmitWorkflowStatus.failed,
              message: failure.message,
            ),
          );
        },
        (data) {
          if (data == "Berhasil") {
            emit(
              state.copyWith(
                submitWorkflowStatus: SubmitWorkflowStatus.success,
              ),
            );
          } else {
            emit(
              state.copyWith(submitWorkflowStatus: SubmitWorkflowStatus.failed),
            );
          }
        },
      );
    });

    // REFERENCE HANDLER
    on<SelectKoridor>((event, emit) async {
      emit(
        state.copyWith(
          status: KmbusStatus.fetching,
          idKoridor: event.id,
          idBus: 0,
        ),
      );

      final resultBus = await kmbusRepository.fetchReferenceBus('', event.id);

      resultBus.fold(
        (failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
        },
        (data) {
          final updatedCreate = _safeCreateAwal().copyWith(
            idKoridor: event.id,
            idBus: 0,
          );

          emit(
            state.copyWith(
              status: KmbusStatus.success,
              referenceBus: data,
              titikAwalCreate: updatedCreate,
            ),
          );
        },
      );
    });

    on<SelectBus>((event, emit) async {
      final nextRitase = await kmbusRepository.fetchNextRitase(
        state.idKoridor,
        event.id,
      );

      nextRitase.fold(
        (failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
        },
        (ritaseValue) {
          final updated = _safeCreateAwal().copyWith(
            idBus: event.id,
            ritaseKe: ritaseValue.ritaseKe,
          );

          emit(state.copyWith(idBus: event.id, titikAwalCreate: updated));
        },
      );
    });
  }

  TitikAwalCreate get _initialTitikAwalCreate => TitikAwalCreate(
    isSubmit: false,
    tanggalKm: DateTime.now().toIso8601String().split('T').first,
    idKoridor: 0,
    ritaseKe: 0,
    idShift: 0,
    idBus: 0,
    idPramugara: 0,
    titikAwal: 0,
    keteranganBus: null,
    document: const [],
  );

  TitikAwalCreate _safeCreateAwal() =>
      state.titikAwalCreate ?? _initialTitikAwalCreate;

  TitikAkhirCreate get _initialTitikAkhirCreate => TitikAkhirCreate(
    processId: null,
    auditTrailId: null,
    isSubmit: false,
    idKm: 0,
    titikAkhir: 0,
    ritaseKe: 0.5,
    document: const [],
  );

}
