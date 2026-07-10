import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/src/either.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:travis/features/kmbus/domain/entities/kmbus_document.dart';
import 'package:travis/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:travis/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:travis/features/kmbus/domain/repositories/kmbus_repository.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_event.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_state.dart';
import 'package:travis/features/reference/domain/entities/document_preview.dart';
import 'package:travis/features/reference/domain/entities/reference_detail.dart';
import 'package:travis/features/timetable/domain/entities/timetable_checkin.dart';

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
        final listAuditTrail = await kmbusRepository.fetchListKmbusAuditTrail(
          '',
        );
        final listHistory = await kmbusRepository.fetchListKmbus('');

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        final kmBusListAuditTrail = listAuditTrail.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        final kmBusListHistory = listHistory.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        if (kmBusListAuditTrail == null || kmBusListHistory == null) return;

        kmBusListHistory.sort((a, b) {
          final dateA = a.tanggalKm != null
              ? DateTime.tryParse(a.tanggalKm!)
              : DateTime(1970);
          final dateB = b.tanggalKm != null
              ? DateTime.tryParse(b.tanggalKm!)
              : DateTime(1970);

          return dateB!.compareTo(dateA!);
        });

        final activeMasterData = kmBusListMaster?.cast<KmbusData?>().firstWhere(
          (e) => e != null && e.titikAkhir == null,
          orElse: () => null,
        );

        final idKm = activeMasterData?.id ?? 0;

        final todayString = DateTime.now().toIso8601String().split('T')[0];

        final bool hasDraftTitikAwal = kmBusListAuditTrail.any((data) {
          final bool isTitikAwal =
              data.dataAfter.titikAwal != null && data.dataAfter.titikAwal != 0;

          final bool isDraft = data.status.code == "DFT";

          final String createdDateString = data.createdDate
              .toLocal()
              .toIso8601String()
              .split('T')[0];
          final bool isToday = createdDateString == todayString;

          final bool isSubmitted = data.dataAfter.isSubmit ?? false;

          return isTitikAwal && isDraft && isToday && !isSubmitted;
        });

        final userIdString = await secureStorageService.readUserId();
        final userId = int.tryParse(userIdString ?? '') ?? 0;

        final todaySchedule = await kmbusRepository.fetchTodaySchedule(userId);

        final todayScheduleData = todaySchedule.fold((failure) {
          emit(
            state.copyWith(
              listKmbusAuditTrail: kmBusListAuditTrail,
              listKmbus: kmBusListHistory,
              idKm: idKm,
              status: KmbusStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (todayScheduleData == null || todayScheduleData.isEmpty) {
          emit(
            state.copyWith(
              listKmbusAuditTrail: kmBusListAuditTrail,
              listKmbus: kmBusListHistory,
              idKm: idKm,
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
          0.5, // Titik Awal selalu dicek di awal hari (ritase 0.5)
        );

        final checkInFuture = kmbusRepository.checkAllowCheckIn(
          idKoridorShift,
          idBusShift,
          ritaseValue,
        );

        final results = await Future.wait([checkAwalFuture, checkInFuture]);

        final checkAwalResult = results[0];
        final checkInResult = results[1];

        final bool hasCheckedIn = checkInResult.fold(
          (_) => false,
          (res) => res.isAllowed,
        );

        final bool hasCreatedTitikAwal = checkAwalResult.fold(
          (_) => false,
          (res) => res.isAllowed,
        );

        final bool isAllowTitikAwal =
            hasCheckedIn && !hasCreatedTitikAwal && !hasDraftTitikAwal;

        String titikAwalMessage = '';
        if (!hasCheckedIn) {
          titikAwalMessage =
              "Silakan lakukan Check-In di Time Table terlebih dahulu.";
        } else if (hasCreatedTitikAwal) {
          titikAwalMessage = "Titik Awal sudah dibuat hari ini.";
        } else if (hasDraftTitikAwal) {
          titikAwalMessage = "Anda memiliki draft Titik Awal yang tertunda.";
        }

        final tanggal = DateTime.now().toIso8601String().split('T')[0];
        final checkin = hasCheckedIn
            ? TimetableCheckin(
                tanggal: tanggal,
                idKoridor: idKoridorShift,
                idBus: idBusShift,
                idShift: todayScheduleData[0].shift.id,
                idPramugara: userId,
                ritaseKe: ritaseValue,
                long: 0.0,
                lat: 0.0,
              )
            : null;

        emit(
          state.copyWith(
            listKmbusAuditTrail: kmBusListAuditTrail,
            listKmbus: kmBusListHistory,
            idKm: idKm,
            checkinData: checkin,
            noUnit: todayScheduleData[0].bus.nomorLambung,
            namaKoridor: todayScheduleData[0].lokasi.namaLokasi,
            disabledCtaMessage: titikAwalMessage,
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

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<PageHistoryLoad>((event, emit) async {
      emit(
        state.copyWith(
          status: KmbusStatus.initial,
          kmbusPage: 1,
          kmbusHasReachedMax: false,
        ),
      );

      try {
        final listMaster = await kmbusRepository.fetchListKmbus('', page: 1);

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        if (kmBusListMaster == null) return;

        kmBusListMaster.sort((a, b) {
          final dateA = a.tanggalKm != null
              ? DateTime.tryParse(a.tanggalKm!)
              : DateTime(1970);
          final dateB = b.tanggalKm != null
              ? DateTime.tryParse(b.tanggalKm!)
              : DateTime(1970);

          return dateB!.compareTo(dateA!);
        });

        emit(
          state.copyWith(
            status: KmbusStatus.success,
            listKmbus: kmBusListMaster,
            kmbusHasReachedMax: kmBusListMaster.length < 10,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<PageHistoryLoadNextPage>((event, emit) async {
      if (state.kmbusHasReachedMax) return;

      final nextPage = state.kmbusPage + 1;

      try {
        final listMaster = await kmbusRepository.fetchListKmbus(
          '',
          page: nextPage,
        );

        final kmBusListMaster = listMaster.fold((failure) {
          return null;
        }, (data) => data);

        if (kmBusListMaster == null) return;

        if (kmBusListMaster.isEmpty) {
          emit(state.copyWith(kmbusHasReachedMax: true));
          return;
        }

        kmBusListMaster.sort((a, b) {
          final dateA = a.tanggalKm != null
              ? DateTime.tryParse(a.tanggalKm!)
              : DateTime(1970);
          final dateB = b.tanggalKm != null
              ? DateTime.tryParse(b.tanggalKm!)
              : DateTime(1970);

          return dateB!.compareTo(dateA!);
        });

        emit(
          state.copyWith(
            listKmbus: List.of(state.listKmbus)..addAll(kmBusListMaster),
            kmbusPage: nextPage,
            kmbusHasReachedMax: kmBusListMaster.length < 10,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
      }
    });

    on<KmbusTitikAwalInputLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.loading));

      try {
        final userRoleIdString = await secureStorageService.readUserRoleId();
        final userRoleId = int.tryParse(userRoleIdString ?? '') ?? 0;

        final resultKoridor = await kmbusRepository.fetchReferenceKoridor('');

        final koridorList = resultKoridor.fold<List<ReferenceDetail>?>((
          failure,
        ) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        if (event.idAuditTrail != null && event.idAuditTrail != 0) {
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

              final busList = resultBus.fold<List<ReferenceDetail>?>((failure) {
                emit(
                  state.copyWith(
                    status: KmbusStatus.error,
                    message: failure.message,
                  ),
                );
                return null;
              }, (data) => data);

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

        final busList = resultBus.fold<List<ReferenceDetail>?>((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

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

        final resultRefDocType = await kmbusRepository.fetchReferenceDocType(
          '',
        );

        resultRefDocType.fold(
          (failure) {
            emit(
              state.copyWith(
                status: KmbusStatus.error,
                message: failure.message,
              ),
            );
          },
          (docTypes) {
            final docTypeId = docTypes.firstWhere((e) => e.code == 'KM').id;

            emit(state.copyWith(idDocType: docTypeId));

            if (kDebugMode) {
              print(docTypeId);
            }
          },
        );

        final initial = _initialTitikAwalCreate.copyWith(
          idPramugara: userRoleId,
          idShift: event.idShift,
          idKoridor: event.idKoridorShift,
          idBus: event.idBusShift,
          ritaseKe: ritaseValue,
          tanggalKm: tanggal,
        );

        if (event.idAuditTrail != null && event.idAuditTrail != 0) {
          final resultDetail = await kmbusRepository.fetchDetailAuditTrailAwal(
            event.idAuditTrail!,
          );

          await resultDetail.fold(
            (failure) async {
              emit(
                state.copyWith(
                  status: KmbusStatus.error,
                  message: failure.message,
                ),
              );
            },
            (titikAwalData) async {
              final previews = titikAwalData.document
                  .map(
                    (doc) => DocumentPreview(
                      idDocument: doc.idDocument,
                      url: doc.urlDoc ?? '',
                    ),
                  )
                  .toList();

              emit(
                state.copyWith(
                  status: KmbusStatus.success,
                  idAuditTrail: event.idAuditTrail!,
                  checkinData: checkin,
                  idShift: event.idShift,
                  idKoridor: event.idKoridorShift,
                  idBus: event.idBusShift,
                  referenceKoridor: koridorList,
                  referenceBus: busList,
                  titikAwalCreate: titikAwalData,
                  documentPreview: previews,
                  ocrResult: titikAwalData.titikAwal == 0
                      ? null
                      : titikAwalData.titikAwal.toString(),
                ),
              );
            },
          );
        } else {
          emit(
            state.copyWith(
              status: KmbusStatus.success,
              idAuditTrail: 0,
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
        }
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<KmbusTitikAkhirInputLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.initial));

      if (kDebugMode) {
        print("event.idKm = ${event.idKm}");
        print("event.idAuditTrail = ${event.idAuditTrail}");
      }

      try {
        int idKoridor = state.idKoridorShift ?? 0;
        int idBus = state.idBusShift ?? 0;
        String namaKoridor = state.namaKoridor ?? '';
        String noUnit = state.noUnit ?? '';

        if (idKoridor == 0 || idBus == 0) {
          final userIdString = await secureStorageService.readUserId();
          final userId = int.tryParse(userIdString ?? '') ?? 0;
          final todaySchedule = await kmbusRepository.fetchTodaySchedule(
            userId,
          );
          todaySchedule.fold((_) {}, (data) {
            if (data.isNotEmpty) {
              idKoridor = data[0].lokasi.koridor;
              idBus = data[0].bus.id ?? 0;
              namaKoridor = data[0].lokasi.namaLokasi;
              noUnit = data[0].bus.nomorLambung;
            }
          });
        }

        double ritaseValue = 0.5;
        if (idKoridor != 0 && idBus != 0) {
          final nextRitaseResult = await kmbusRepository.fetchNextRitase(
            idKoridor,
            idBus,
          );
          nextRitaseResult.fold((_) {}, (value) {
            ritaseValue = value.ritaseKe ?? 0.5;
          });
        }

        final initial = _initialTitikAkhirCreate.copyWith(
          idKm: event.idKm,
          auditTrailId: event.idAuditTrail,
          ritaseKe: ritaseValue,
        );

        if (event.idAuditTrail != null && event.idAuditTrail != 0) {
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
              if (kDebugMode) {
                print(titikAkhirData);
              }
              emit(
                state.copyWith(
                  status: KmbusStatus.success,
                  titikAkhirCreate: titikAkhirData.copyWith(
                    idKm: event.idKm,
                    ritaseKe: ritaseValue != 0.5
                        ? ritaseValue
                        : (titikAkhirData.ritaseKe ?? 0.5),
                  ),
                  ocrResult: titikAkhirData.titikAkhir.toString(),
                  namaKoridor: namaKoridor,
                  noUnit: noUnit,
                  idKoridorShift: idKoridor,
                  idBusShift: idBus,
                ),
              );
            },
          );
        } else {
          emit(
            state.copyWith(
              status: KmbusStatus.success,
              titikAkhirCreate: initial,
              namaKoridor: namaKoridor,
              noUnit: noUnit,
              idKoridorShift: idKoridor,
              idBusShift: idBus,
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
                idDocumentType: state.idDocType,
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

          ocrResult:
              updatedPreview.isEmpty &&
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

      Either<Failure, String> result;

      if (event.idAuditTrail != null && event.idAuditTrail != 0) {
        result = await kmbusRepository.updateTitikAwal(
          state.titikAwalCreate!,
          event.idAuditTrail!,
        );
      } else {
        result = await kmbusRepository.createTitikAwal(state.titikAwalCreate!);
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
              idAuditTrail:
                  (event.idAuditTrail == null || event.idAuditTrail == 0)
                  ? int.parse(data)
                  : state.idAuditTrail,
            ),
          );
        },
      );
    });

    on<SubmitTitikAkhir>((event, emit) async {
      emit(state.copyWith(submitStatus: SubmitStatus.submitting));

      Either<Failure, String> result;

      if (event.idAuditTrail != null && event.idAuditTrail != 0) {
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
              idAuditTrail:
                  (event.idAuditTrail == null || event.idAuditTrail == 0)
                  ? int.parse(data)
                  : state.idAuditTrail,
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
        event.idAuditTrail != 0 ? event.idAuditTrail : state.idAuditTrail,
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
