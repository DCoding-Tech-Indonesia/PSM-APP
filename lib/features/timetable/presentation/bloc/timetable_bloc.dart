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
      emit(state.copyWith(status: TimetableStatus.loading));

      try {
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
              jadwalExist: false
            ),
          );
          return;
        }


        final idKoridorShift = todayScheduleData[0].lokasi.koridor;
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

        final currentCheckin =
            state.checkinData ??
            TimetableCheckin(
              tanggal: DateTime.now().toString().split(' ')[0],
              idKoridor: idKoridorShift,
              idBus: idBusShift,
              idShift: idShiftActive,
              idPramugara: userId,
              ritaseKe: ritaseValue,
              long: 0.0,
              lat: 0.0,
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

        final list = await timetableRepository.fetchListTimeTable('');
        final timeTableList = list.fold((failure) {
          return null;
        }, (data) {
          return data;
        });

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
          (res) => res == "Access Granted",
        );

        final bool isAllowCheckOut = allowResults[1].fold(
          (_) => false,
          (res) => res == "Access Granted",
        );

        final listMaster = await timetableRepository.fetchKmbusDataToday('');

        final kmBusListMaster = listMaster.fold((failure) {
          emit(
            state.copyWith(status: TimetableStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        final activeMasterData = kmBusListMaster?.cast<KmbusData?>().firstWhere(
              (e) => e != null && e.titikAkhir == null,
          orElse: () => null,
        );

        final idKm = activeMasterData?.id ?? 0;

        emit(
          state.copyWith(
            idKm: idKm,
            idCheckin: idCheckin,
            listTimetable: timeTableList,
            referenceKoridor: koridorList,
            referenceBus: busList,
            checkinData: updatedCheckinWithPramugara,
            idKoridor: idKoridorShift,
            idBus: idBusShift,
            noUnit: currentNoUnit,
            isAllowCheckIn: isAllowCheckIn,
            isAllowCheckOut: (isAllowCheckOut && !isAllowCheckIn),
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
            emit(
              state.copyWith(
                status: data != null
                    ? TimetableStatus.successSave
                    : TimetableStatus.failedSave,
                message: data != null
                    ? "Berhasil check-in!"
                    : "Gagal check-in!",
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
            emit(
              state.copyWith(
                status: TimetableStatus.successSave,
                message: "Berhasil check-out!",
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

    on<SelectKoridor>((event, emit) async {
      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: event.id,
            idBus: 0,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0.0,
            long: 0.0,
            lat: 0.0,
          );

      emit(
        state.copyWith(
          status: TimetableStatus.fetching,
          checkinData: currentCheckin.copyWith(
            idKoridor: event.id,
            idBus: 0,
            ritaseKe: 0.0,
          ),
          idKoridor: event.id,
          namaKoridor: event.namaKoridor,
          idBus: 0,
          referenceBus: const [],
        ),
      );

      final resultBus = await timetableRepository.fetchReferenceBus(
        '',
        event.id,
      );

      resultBus.fold(
        (failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(status: TimetableStatus.success, referenceBus: data),
          );
        },
      );
    });

    on<SelectBus>((event, emit) async {
      emit(
        state.copyWith(
          status: TimetableStatus.fetching,
          idBus: event.id,
          noUnit: event.noUnit,
        ),
      );

      final nextRitase = await timetableRepository.fetchNextRitase(
        state.idKoridor,
        event.id,
      );

      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: state.idKoridor,
            idBus: event.id,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0.0,
            long: 0.0,
            lat: 0.0,
          );

      nextRitase.fold(
        (failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
        },
        (ritaseValue) {
          emit(
            state.copyWith(
              status: TimetableStatus.success,
              checkinData: currentCheckin.copyWith(
                idKoridor: state.idKoridor,
                idBus: event.id,
                ritaseKe: ritaseValue.ritaseKe!,
              ),
            ),
          );
        },
      );
    });

    on<ResetInput>((event, emit) {
      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: 0,
            idBus: 0,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0.0,
            long: 0.0,
            lat: 0.0,
          );

      emit(
        state.copyWith(
          status: TimetableStatus.success,
          idKoridor: 0,
          namaKoridor: '',
          idBus: 0,
          referenceBus: const [],
          checkinData: currentCheckin.copyWith(
            idKoridor: 0,
            idBus: 0,
            ritaseKe: 0.0,
          ),
        ),
      );
    });
  }
}
