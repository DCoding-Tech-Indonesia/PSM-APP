import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:collection/collection.dart';
import 'package:travis/core/error/failure.dart';
import 'package:travis/core/presentations/entity/core_schedule_model.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:travis/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:travis/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:travis/features/timetable/domain/entities/timetable_data.dart';
import 'package:travis/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:travis/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:travis/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository timetableRepository;
  final SecureStorageService secureStorageService;

  TimetableBloc(this.timetableRepository, this.secureStorageService)
    : super(const TimetableState()) {
    on<PageDashboardLoad>((event, emit) async {
      emit(state.copyWith(status: TimetableStatus.initial));

      try {
        final userIdString = await secureStorageService.getActiveUserId();
        final userId = int.tryParse(userIdString ?? '') ?? 0;

        // Run independent calls in parallel (Step 1)
        final resultsStep1 = await Future.wait([
          timetableRepository.fetchListTimeTable(''),
          timetableRepository.fetchKmbusDataToday(''),
          timetableRepository.checkAbsenceExist(state.long, state.lat),
          if (userId != 0) timetableRepository.fetchTodaySchedule(userId),
        ]);

        final listResult =
            resultsStep1[0] as Either<Failure, List<TimetableData>>;
        final listMasterResult =
            resultsStep1[1] as Either<Failure, List<KmbusData>>;
        final isAlreadyTakeAttendanceResult =
            resultsStep1[2] as Either<Failure, bool?>;
        final todayScheduleResult = userId != 0
            ? resultsStep1[3] as Either<Failure, List<CoreScheduleModel>>
            : null;

        final timeTableList = listResult.fold((_) => null, (data) => data);
        timeTableList?.sort((a, b) {
          final jamA = a.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : a.jamBerangkat.split('.').first;
          final jamB = b.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : b.jamBerangkat.split('.').first;
          final dateTimeA = DateTime.parse('${a.tanggal} $jamA');
          final dateTimeB = DateTime.parse('${b.tanggal} $jamB');
          return dateTimeB.compareTo(dateTimeA);
        });

        emit(state.copyWith(listTimetable: timeTableList));

        if (todayScheduleResult == null) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: "Jadwal tidak ditemukan",
              jadwalExist: false,
            ),
          );
          return;
        }

        final todayScheduleData = todayScheduleResult.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (todayScheduleData == null || todayScheduleData.isEmpty) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: "Jadwal tidak ditemukan",
              jadwalExist: false,
            ),
          );
          return;
        }

        final idKoridorShift = todayScheduleData[0].lokasi.koridor;
        final namaKoridorShift = todayScheduleData[0].lokasi.namaLokasi;
        final idBusShift = todayScheduleData[0].bus.id;
        final idShiftActive = todayScheduleData[0].shift.id;
        final currentNoUnit = todayScheduleData[0].bus.nomorLambung;

        // Fetch Next Ritase (Step 2)
        final nextRitaseResult = await timetableRepository.fetchNextRitase(
          idKoridorShift,
          idBusShift!,
        );

        final double ritaseValue = nextRitaseResult.fold(
          (_) => 0.0,
          (value) => value.ritaseKe!,
        );
        final bool isLastRitase = nextRitaseResult.fold(
          (_) => false,
          (value) => value.isLastRitase!,
        );
        final bool? isNextRitase = nextRitaseResult.fold(
          (_) => null,
          (value) => value.isNextRitase,
        );

        // Run checks and verify check-in/out allow states in parallel (Step 3)
        final checkResults = await Future.wait([
          timetableRepository.checkAllowCheckIn(
            idKoridorShift,
            idBusShift,
            ritaseValue,
          ),
          timetableRepository.checkAllowCheckOut(
            idKoridorShift,
            idBusShift,
            ritaseValue,
          ),
        ]);

        final checkInAllowResult = checkResults[0];
        final checkOutAllowResult = checkResults[1];

        final bool hasCheckedIn = checkInAllowResult.fold(
          (_) => false,
          (res) => res.isAllowed,
        );
        final String checkInMessage = checkInAllowResult.fold(
          (_) => '',
          (res) => res.message,
        );
        final bool hasCheckedOut = checkOutAllowResult.fold(
          (_) => false,
          (res) => res.isAllowed,
        );
        final String checkOutMessage = checkOutAllowResult.fold(
          (_) => '',
          (res) => res.message,
        );

        final kmBusListMaster = listMasterResult.fold(
          (_) => null,
          (data) => data,
        );
        final activeMasterData = kmBusListMaster?.firstWhereOrNull(
          (e) => e.titikAkhir == null,
        );
        final idKm = activeMasterData?.id ?? 0;

        final bool? isAlreadyTakeAttendanceRestule =
            isAlreadyTakeAttendanceResult.fold((failure) {
              emit(
                state.copyWith(
                  status: TimetableStatus.error,
                  message: failure.message,
                ),
              );
              return null;
            }, (data) => data ?? false);

        if (isAlreadyTakeAttendanceRestule == null) return;

        final activeCheckin = timeTableList?.firstWhereOrNull(
          (e) => e.jamDatang.trim().isEmpty,
        );
        final int? idCheckin = activeCheckin?.id;

        final currentCheckin =
            state.checkinData ??
            TimetableCheckin(
              tanggal: DateTime.now().toString().split(' ')[0],
              idKoridor: idKoridorShift,
              idBus: idBusShift,
              idShift: idShiftActive,
              idPramugara: userId,
              ritaseKe: ritaseValue,
              long: state.long,
              lat: state.lat,
            );

        final bool isLastRitaseCompleted =
            isLastRitase &&
            (timeTableList?.any(
                  (e) =>
                      e.ritaseKe == ritaseValue &&
                      e.jamDatang.trim().isNotEmpty,
                ) ??
                false);

        // Cari ritase tertinggi yang sudah selesai sepenuhnya (sudah check-in dan sudah check-out)
        double highestCompletedRitase = 0.0;
        if (timeTableList != null) {
          for (var e in timeTableList) {
            if (e.jamBerangkat.trim().isNotEmpty &&
                e.jamDatang.trim().isNotEmpty) {
              if (e.ritaseKe > highestCompletedRitase) {
                highestCompletedRitase = e.ritaseKe;
              }
            }
          }
        }

        double displayRitase = ritaseValue;
        bool finalAllowCheckIn =
            !isLastRitaseCompleted &&
            !hasCheckedIn &&
            isAlreadyTakeAttendanceRestule;
        bool finalAllowCheckOut = hasCheckedIn && !hasCheckedOut;

        if (activeCheckin != null) {
          // Ada ritase yang sedang berjalan (sudah check-in tapi belum check-out)
          displayRitase = activeCheckin.ritaseKe;
          finalAllowCheckIn = false;
          finalAllowCheckOut = true;
        } else if (highestCompletedRitase > 0.0) {
          // Ada ritase yang sudah selesai sepenuhnya, gunakan ritase dari backend
          displayRitase = ritaseValue;
          finalAllowCheckIn =
              !isLastRitaseCompleted && isAlreadyTakeAttendanceRestule;
          finalAllowCheckOut = false;
        } else {
          // Tidak ada ritase berjalan atau selesai, gunakan logic normal
          if (hasCheckedIn && hasCheckedOut && !isLastRitase) {
            displayRitase = ritaseValue;
            finalAllowCheckIn = isAlreadyTakeAttendanceRestule;
            finalAllowCheckOut = false;
          }
        }

        final updatedCheckinWithPramugara = currentCheckin.copyWith(
          idKoridor: idKoridorShift,
          idBus: idBusShift,
          idShift: idShiftActive,
          idPramugara: userId,
          ritaseKe: displayRitase,
        );

        emit(
          state.copyWith(
            isLastRitase: isLastRitase,
            isNextRitase: isNextRitase,
            idShift: idShiftActive,
            idKm: idKm,
            ritaseKe: displayRitase,
            idCheckin: idCheckin,
            checkinData: updatedCheckinWithPramugara,
            idKoridor: idKoridorShift,
            namaKoridor: namaKoridorShift,
            idBus: idBusShift,
            noUnit: currentNoUnit,
            isAllowCheckIn: finalAllowCheckIn,
            isAllowCheckOut: finalAllowCheckOut,
            disabledBerangkatMessage: isLastRitaseCompleted
                ? "Semua ritase hari ini telah diselesaikan."
                : (!isAlreadyTakeAttendanceRestule
                      ? "Harap ambil absensi terlebih dahulu."
                      : checkInMessage),
            disabledDatangMessage: checkOutMessage,
            status: TimetableStatus.success,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(
          state.copyWith(status: TimetableStatus.error, message: e.toString()),
        );
      }
    });

    on<PageHistoryLoad>((event, emit) async {
      emit(
        state.copyWith(
          status: TimetableStatus.loading,
          page: 1,
          hasReachedMax: false,
        ),
      );

      try {
        final list = await timetableRepository.fetchListTimeTable('', page: 1);
        final timeTableList = list.fold(
          (failure) {
            return null;
          },
          (data) {
            return data;
          },
        );

        if (timeTableList == null) return;

        timeTableList.sort((a, b) {
          final jamA = a.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : a.jamBerangkat.split('.').first;

          final jamB = b.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : b.jamBerangkat.split('.').first;

          final dateTimeA = DateTime.parse('${a.tanggal} $jamA');
          final dateTimeB = DateTime.parse('${b.tanggal} $jamB');

          return dateTimeB.compareTo(dateTimeA);
        });

        emit(
          state.copyWith(
            status: TimetableStatus.success,
            listTimetable: timeTableList,
            hasReachedMax: timeTableList.length < 10,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(
          state.copyWith(status: TimetableStatus.error, message: e.toString()),
        );
      }
    });

    on<PageHistoryLoadNextPage>((event, emit) async {
      if (state.hasReachedMax || state.status == TimetableStatus.fetching) {
        return;
      }

      emit(state.copyWith(status: TimetableStatus.fetching));

      final nextPage = state.page + 1;

      try {
        final list = await timetableRepository.fetchListTimeTable(
          '',
          page: nextPage,
        );
        final timeTableList = list.fold(
          (failure) {
            return null;
          },
          (data) {
            return data;
          },
        );

        if (timeTableList == null) {
          emit(state.copyWith(status: TimetableStatus.success));
          return;
        }

        if (timeTableList.isEmpty) {
          emit(
            state.copyWith(
              hasReachedMax: true,
              status: TimetableStatus.success,
            ),
          );
          return;
        }

        timeTableList.sort((a, b) {
          final jamA = a.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : a.jamBerangkat.split('.').first;

          final jamB = b.jamBerangkat.trim().isEmpty
              ? '00:00:00'
              : b.jamBerangkat.split('.').first;

          final dateTimeA = DateTime.parse('${a.tanggal} $jamA');
          final dateTimeB = DateTime.parse('${b.tanggal} $jamB');

          return dateTimeB.compareTo(dateTimeA);
        });

        emit(
          state.copyWith(
            listTimetable: List.of(state.listTimetable)..addAll(timeTableList),
            page: nextPage,
            hasReachedMax: timeTableList.length < 10,
            status: TimetableStatus.success,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(state.copyWith(status: TimetableStatus.success));
      }
    });

    on<LocationLoaded>((event, emit) async {
      final idUserStr = await secureStorageService.getActiveUserId();
      final idUser = int.tryParse(idUserStr ?? '') ?? 0;

      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: state.idKoridor,
            idBus: state.idBus,
            idShift: 1,
            idPramugara: idUser,
            ritaseKe: 0.0,
            long: event.long,
            lat: event.lat,
          );

      emit(
        state.copyWith(
          status: TimetableStatus.initial,
          lat: event.lat,
          long: event.long,
          checkinData: currentCheckin.copyWith(
            idKoridor: state.idKoridor,
            idBus: state.idBus,
            lat: event.lat,
            long: event.long,
          ),
        ),
      );
    });

    on<CheckInTimetable>((event, emit) async {
      if (state.checkinData == null || !state.checkinData!.isSubmittable) {
        final errorMessage =
            state.checkinData?.validationErrorMessage ?? "Data tidak valid";

        emit(
          state.copyWith(
            status: TimetableStatus.failedSave,
            message: errorMessage,
          ),
        );
        return;
      }

      emit(state.copyWith(status: TimetableStatus.onSubmit));

      try {
        final result = await timetableRepository.checkinTimeTable(
          state.checkinData!,
        );

        result.fold(
          (failure) {
            emit(
              state.copyWith(
                status: TimetableStatus.failedSave,
                message: "Gagal check-in!",
              ),
            );
          },
          (data) {
            if (data == null) {
              emit(
                state.copyWith(
                  status: TimetableStatus.failedSave,
                  message: "Gagal check-in!",
                ),
              );
              return;
            }

            emit(
              state.copyWith(
                status: data.status
                    ? TimetableStatus.successCheckIn
                    : TimetableStatus.failedSave,
                message: data.message,
                isAllowCheckIn: data.status ? false : state.isAllowCheckIn,
                isAllowCheckOut: data.status ? true : state.isAllowCheckOut,
              ),
            );
          },
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: TimetableStatus.failedSave,
            message: e.toString(),
          ),
        );
      }
    });

    on<CheckOutTimetable>((event, emit) async {
      if (state.idCheckin == null) {
        emit(
          state.copyWith(
            status: TimetableStatus.failedSave,
            message: "Data check-in tidak ditemukan",
          ),
        );
        return;
      }

      if (state.checkinData == null) {
        emit(
          state.copyWith(
            status: TimetableStatus.failedSave,
            message: "Lokasi belum tersedia",
          ),
        );
        return;
      }

      emit(state.copyWith(status: TimetableStatus.onSubmit));

      try {
        final payload = TimetableCheckout(
          idTimeTableRitase: state.idCheckin!,
          lat: state.checkinData!.lat,
          long: state.checkinData!.long,
        );

        final result = await timetableRepository.checkoutTimeTable(payload);

        result.fold(
          (failure) {
            emit(
              state.copyWith(
                status: TimetableStatus.failedSave,
                message: failure.message,
              ),
            );
          },
          (data) {
            if (data == null) {
              emit(
                state.copyWith(
                  status: TimetableStatus.failedSave,
                  message: "Gagal check-out!",
                ),
              );
              return;
            }

            emit(
              state.copyWith(
                status: data.status
                    ? TimetableStatus.successCheckOut
                    : TimetableStatus.failedSave,
                message: data.message,
                isAllowCheckOut: data.status ? false : state.isAllowCheckOut,
                clearCheckinState: data.status ? true : false,
              ),
            );
          },
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: TimetableStatus.failedSave,
            message: e.toString(),
          ),
        );
      }
    });
  }
}
