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
        final bool isLastRitase = nextRitaseResult.fold(
          (_) => false,
          (value) => value.isLastRitase ?? false,
        );
        final bool? isNextRitase = nextRitaseResult.fold(
          (_) => null,
          (value) => value.isNextRitase,
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
            hasCheckedIn &&
            !hasCreatedTitikAwal &&
            !hasDraftTitikAwal &&
            !isLastRitase;

        String titikAwalMessage = '';
        if (!hasCheckedIn) {
          titikAwalMessage =
              "Silakan lakukan Check-In di Time Table terlebih dahulu.";
        } else if (isLastRitase) {
          titikAwalMessage =
              "Ritase terakhir, silakan isi Titik Akhir terlebih dahulu.";
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
            ritaseKe: ritaseValue,
            isLastRitase: isLastRitase,
            isNextRitase: isNextRitase,
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
      // Clear temporary upload data saat form init (jangan tampilkan data bekas)
      emit(state.copyWith(
        status: KmbusStatus.loading,
        ocrResult: null,
        speedometerImage: null,
        documentPreview: [],
        uploadStatus: UploadStatus.idling,
      ));

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

              // Fetch today's schedule to get corridor and bus names for edit mode
              String namaKoridor = '';
              String noUnit = '';
              final userIdString = await secureStorageService.readUserId();
              final userId = int.tryParse(userIdString ?? '') ?? 0;
              final todaySchedule = await kmbusRepository.fetchTodaySchedule(userId);
              todaySchedule.fold((_) {}, (data) {
                if (data.isNotEmpty) {
                  namaKoridor = data[0].lokasi.namaLokasi;
                  noUnit = data[0].bus.nomorLambung;
                }
              });

              emit(
                state.copyWith(
                  status: KmbusStatus.success,

                  idShift: titikAwalData.idShift,
                  idKoridor: titikAwalData.idKoridor,
                  idBus: titikAwalData.idBus,

                  namaKoridor: namaKoridor,
                  noUnit: noUnit,

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

        // Fetch today's schedule to get corridor and bus names
        String namaKoridor = '';
        String noUnit = '';
        final userIdString = await secureStorageService.readUserId();
        final userId = int.tryParse(userIdString ?? '') ?? 0;
        final todaySchedule = await kmbusRepository.fetchTodaySchedule(userId);
        todaySchedule.fold((_) {}, (data) {
          if (data.isNotEmpty) {
            namaKoridor = data[0].lokasi.namaLokasi;
            noUnit = data[0].bus.nomorLambung;
          }
        });

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
                  namaKoridor: namaKoridor,
                  noUnit: noUnit,
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
              namaKoridor: namaKoridor,
              noUnit: noUnit,
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
      // Clear temporary upload data saat form init (jangan tampilkan data bekas)
      emit(state.copyWith(
        status: KmbusStatus.initial,
        ocrResult: null,
        speedometerImage: null,
        documentPreview: [],
        uploadStatus: UploadStatus.idling,
      ));

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

        // Fetch list KmbusData untuk display detail perjalanan
        final listKmbusResult = await kmbusRepository.fetchListKmbus('');
        final listKmbus = listKmbusResult.fold(
          (failure) => <KmbusData>[],
          (data) => data,
        );

        // Fetch running KM detail untuk memastikan data entry terbaru tersedia
        List<KmbusData> finalListKmbus = listKmbus;
        if (idKoridor != 0 && idBus != 0) {
          final runningKmResult = await kmbusRepository.fetchRunningKmDetail(
            idKoridor,
            idBus,
          );
          final runningKmDetail = runningKmResult.fold(
            (failure) => null,
            (data) => data,
          );

          // Jika data ditemukan, pastikan ada di list (replace atau tambahkan)
          if (runningKmDetail != null) {
            final existingIndex = finalListKmbus.indexWhere(
              (km) => km.id == runningKmDetail.id,
            );
            if (existingIndex >= 0) {
              // Update existing entry dengan data terbaru
              finalListKmbus = [
                ...finalListKmbus.sublist(0, existingIndex),
                runningKmDetail,
                ...finalListKmbus.sublist(existingIndex + 1),
              ];
            } else {
              // Tambahkan entry baru
              finalListKmbus = [...finalListKmbus, runningKmDetail];
            }
          }
        }

        if (event.idAuditTrail != null && event.idAuditTrail != 0) {
          final resultAkhir = await kmbusRepository.fetchDetailAuditTrailAkhir(
            event.idAuditTrail!,
          );

          final resultAwal = await kmbusRepository.fetchDetailAuditTrailAwal(
            event.idAuditTrail!,
          );

          final titikAkhirData = resultAkhir.fold(
            (failure) => null,
            (data) => data,
          );

          final titikAwalData = resultAwal.fold(
            (failure) => null,
            (data) => data,
          );

          if (titikAkhirData == null) {
            emit(
              state.copyWith(
                status: KmbusStatus.error,
                message: "Gagal memuat data titik akhir",
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: KmbusStatus.success,
                titikAkhirCreate: titikAkhirData.copyWith(
                  idKm: event.idKm,
                  ritaseKe: ritaseValue != 0.5
                      ? ritaseValue
                      : titikAkhirData.ritaseKe,
                ),
                titikAwalCreate: titikAwalData,
                ocrResult: titikAkhirData.titikAkhir.toString(),
                namaKoridor: namaKoridor,
                noUnit: noUnit,
                idKoridorShift: idKoridor,
                idBusShift: idBus,
                listKmbus: finalListKmbus,
              ),
            );
          }
        } else {
          emit(
            state.copyWith(
              status: KmbusStatus.success,
              titikAkhirCreate: initial,
              namaKoridor: namaKoridor,
              noUnit: noUnit,
              idKoridorShift: idKoridor,
              idBusShift: idBus,
              listKmbus: finalListKmbus,
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

          // HANYA simpan temporary OCR result, jangan upload dokumen dulu
          // Dokumen akan di-upload saat user klik Konfirmasi
          emit(
            state.copyWith(
              uploadStatus: UploadStatus.successDocs,
              documentUploadStatus: DocumentUploadStatus.success,
              ocrResult: ocrValue,
              speedometerImage: event.file,
            ),
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
              final newPreview = DocumentPreview(
                idDocument: data.idDocument,
                url: data.url,
              );

              // HANYA simpan temporary data (image & document preview)
              // Odometer value baru disimpan saat user konfirmasi di dialog
              emit(
                state.copyWith(
                  uploadStatus: UploadStatus.successDocs,
                  documentUploadStatus: DocumentUploadStatus.success,
                  ocrResult: ocrValue, // Temporary untuk ditampilkan di dialog
                  speedometerImage: event.file,
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

      // Jika semua preview dan document kosong, hapus OCR result juga
      final hasNoDocuments = updatedPreview.isEmpty &&
          updatedDocsAwal.isEmpty &&
          updatedDocsAkhir.isEmpty;

      emit(
        state.copyWith(
          documentPreview: updatedPreview,
          titikAwalCreate: state.titikAwalCreate?.copyWith(
            document: updatedDocsAwal,
          ),
          titikAkhirCreate: state.titikAkhirCreate?.copyWith(
            document: updatedDocsAkhir,
          ),
          // Hapus OCR result jika tidak ada dokumen apapun
          ocrResult: hasNoDocuments ? null : state.ocrResult,
          speedometerImage: hasNoDocuments ? null : state.speedometerImage,
          uploadStatus: hasNoDocuments ? UploadStatus.idling : state.uploadStatus,
        ),
      );
    });

    on<ResetUploadStatus>((event, emit) {
      emit(
        state.copyWith(
          uploadStatus: UploadStatus.idling,
          ocrResult: null,
          speedometerImage: null,
          documentPreview: [], // Clear temporary preview juga
        ),
      );
    });

    on<EditOdometerAwal>((event, emit) async {
      final create = state.titikAwalCreate ?? _initialTitikAwalCreate;
      final speedometerFile = state.speedometerImage;

      // If there's a speedometer image, upload it now (deferred upload on confirmation)
      if (speedometerFile != null) {
        emit(state.copyWith(
          documentUploadStatus: DocumentUploadStatus.uploading,
        ));

        final uploadResult = await kmbusRepository.uploadDocument(speedometerFile);

        final uploadedDoc = uploadResult.fold<KmbusDocument?>(
          (failure) {
            emit(
              state.copyWith(
                documentUploadStatus: DocumentUploadStatus.failed,
                message: failure.message,
                uploadStatus: UploadStatus.idling,
                speedometerImage: null,
              ),
            );
            return null;
          },
          (documentData) {
            return KmbusDocument(
              idKmDocument: documentData.idDocument,
              idDocument: documentData.idDocument,
              idDocumentType: state.idDocType,
              urlDoc: documentData.url,
            );
          },
        );

        if (uploadedDoc == null) return;

        emit(
          state.copyWith(
            ocrResult: event.odometerVal.toString(),
            titikAwalCreate: create.copyWith(
              titikAwal: event.odometerVal,
              document: [...create.document, uploadedDoc],
            ),
            documentUploadStatus: DocumentUploadStatus.success,
            documentPreview: [],
            speedometerImage: null,
            uploadStatus: UploadStatus.idling,
          ),
        );
      } else {
        // No image to upload, just update odometer value
        emit(
          state.copyWith(
            ocrResult: event.odometerVal.toString(),
            titikAwalCreate: create.copyWith(
              titikAwal: event.odometerVal,
            ),
            documentPreview: [],
            speedometerImage: null,
            uploadStatus: UploadStatus.idling,
          ),
        );
      }
    });

    on<EditOdometerAkhir>((event, emit) async {
      final create = state.titikAkhirCreate ?? _initialTitikAkhirCreate;
      final speedometerFile = state.speedometerImage;

      // If there's a speedometer image, upload it now (deferred upload on confirmation)
      if (speedometerFile != null) {
        emit(state.copyWith(
          documentUploadStatus: DocumentUploadStatus.uploading,
        ));

        final uploadResult = await kmbusRepository.uploadDocument(speedometerFile);

        final uploadedDoc = uploadResult.fold<KmbusDocument?>(
          (failure) {
            emit(
              state.copyWith(
                documentUploadStatus: DocumentUploadStatus.failed,
                message: failure.message,
                uploadStatus: UploadStatus.idling,
                speedometerImage: null,
              ),
            );
            return null;
          },
          (documentData) {
            return KmbusDocument(
              idKmDocument: documentData.idDocument,
              idDocument: documentData.idDocument,
              idDocumentType: 72,
              urlDoc: documentData.url,
            );
          },
        );

        if (uploadedDoc == null) return;

        emit(
          state.copyWith(
            ocrResult: event.odometerVal.toString(),
            titikAkhirCreate: create.copyWith(
              titikAkhir: event.odometerVal,
              document: [...create.document, uploadedDoc],
            ),
            documentUploadStatus: DocumentUploadStatus.success,
            documentPreview: [],
            speedometerImage: null,
            uploadStatus: UploadStatus.idling,
          ),
        );
      } else {
        // No image to upload, just update odometer value
        emit(
          state.copyWith(
            ocrResult: event.odometerVal.toString(),
            titikAkhirCreate: create.copyWith(
              titikAkhir: event.odometerVal,
            ),
            documentPreview: [],
            speedometerImage: null,
            uploadStatus: UploadStatus.idling,
          ),
        );
      }
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
