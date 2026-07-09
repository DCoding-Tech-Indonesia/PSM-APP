import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';
import 'package:psm_mobile/features/timetable/domain/repositories/timetable_repository.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository timetableRepository;
  final SecureStorageService secureStorageService;

  TimetableBloc(this.timetableRepository, this.secureStorageService)
    : super(const TimetableState()) {
    on<PageDashboardLoad>((event, emit) async {
      emit(state.copyWith(status: TimetableStatus.initial));

      try {
        final list = await timetableRepository.fetchListTimeTable('');
        final timeTableList = list.fold(
          (failure) {
            return null;
          },
          (data) {
            return data;
          },
        );

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

        final userIdString = await secureStorageService.readUserId();
        final userId = int.tryParse(userIdString ?? '') ?? 0;

        final todaySchedule = await timetableRepository.fetchTodaySchedule(
          userId,
        );

        final todayScheduleData = todaySchedule.fold((failure) {
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

        final resultBus = await timetableRepository.fetchReferenceBus(
          '',
          idKoridorShift,
        );
        final busList = resultBus.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (busList == null) return;

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

        final updatedCheckinWithPramugara = currentCheckin.copyWith(
          idKoridor: idKoridorShift,
          idBus: idBusShift,
          idShift: idShiftActive,
          idPramugara: userId,
          ritaseKe: ritaseValue,
        );

        final resultKoridor = await timetableRepository.fetchReferenceKoridor(
          '',
        );
        final koridorList = resultKoridor.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        final activeCheckin = timeTableList?.cast<TimetableData?>().firstWhere(
          (e) => e != null && (e.jamDatang.trim().isEmpty),
          orElse: () => null,
        );

        final int? idCheckin = activeCheckin?.id;

        final checkCheckInFuture = timetableRepository.checkAllowCheckIn(
          updatedCheckinWithPramugara.idKoridor,
          updatedCheckinWithPramugara.idBus,
          updatedCheckinWithPramugara.ritaseKe,
        );

        final checkCheckOutFuture = timetableRepository.checkAllowCheckOut(
          updatedCheckinWithPramugara.idKoridor,
          updatedCheckinWithPramugara.idBus,
          updatedCheckinWithPramugara.ritaseKe,
        );

        final allowResults = await Future.wait([
          checkCheckInFuture,
          checkCheckOutFuture,
        ]);

        final bool isAllowCheckIn = allowResults[0].fold(
          (_) => false,
          (res) => res.isAllowed,
        );

        final String checkInMessage = allowResults[0].fold(
          (_) => '',
          (res) => res.message,
        );

        final bool isAllowCheckOut = allowResults[1].fold(
          (_) => false,
          (res) => res.isAllowed,
        );

        final String checkOutMessage = allowResults[1].fold(
          (_) => '',
          (res) => res.message,
        );

        final listMaster = await timetableRepository.fetchKmbusDataToday('');

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        final activeMasterData = kmBusListMaster?.cast<KmbusData?>().firstWhere(
          (e) => e != null && e.titikAkhir == null,
          orElse: () => null,
        );

        final idKm = activeMasterData?.id ?? 0;

        final isAlreadyTakeAttendance = await timetableRepository.checkAbsenceExist(state.long, state.lat);

        final isAlreadyTakeAttendanceRestule = isAlreadyTakeAttendance.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        emit(
          state.copyWith(
            isLastRitase: isLastRitase,
            idShift: idShiftActive,
            idKm: idKm,
            ritaseKe: ritaseValue,
            idCheckin: idCheckin,
            referenceKoridor: koridorList,
            referenceBus: busList,
            checkinData: updatedCheckinWithPramugara,
            idKoridor: idKoridorShift,
            namaKoridor: namaKoridorShift,
            idBus: idBusShift,
            noUnit: currentNoUnit,
            isAllowCheckIn: !isAllowCheckIn && isAlreadyTakeAttendanceRestule!,
            isAllowCheckOut: !isAllowCheckOut,
            disabledBerangkatMessage: isAlreadyTakeAttendanceRestule! ? "Harap ambil absensi terlebih dahulu." : checkInMessage,
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
      try {
        final list = await timetableRepository.fetchListTimeTable('');
        final timeTableList = list.fold(
          (failure) {
            return null;
          },
          (data) {
            return data;
          },
        );

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
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(
          state.copyWith(status: TimetableStatus.error, message: e.toString()),
        );
      }
    });

    on<LocationLoaded>((event, emit) {
      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: state.idKoridor,
            idBus: state.idBus,
            idShift: 1,
            idPramugara: 0,
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
                message: "Gagal check-out!",
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
