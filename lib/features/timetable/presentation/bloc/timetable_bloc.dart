import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
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
          (value) => value,
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
              long: 0,
              lat: 0,
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

        if (koridorList == null) return;

        final list = await timetableRepository.fetchListTimeTable('');
        final timeTableList = list.fold((failure) {
          emit(
            state.copyWith(
              status: TimetableStatus.error,
              message: failure.message,
            ),
          );
          return null;
        }, (data) => data);

        if (timeTableList == null) return;

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

        emit(
          state.copyWith(
            listTimetable: timeTableList,
            referenceKoridor: koridorList,
            referenceBus: busList, // 🛠️ Set list data reference bus ke state
            checkinData: updatedCheckinWithPramugara,
            idKoridor: idKoridorShift,
            idBus: idBusShift,
            noUnit: currentNoUnit, // 🛠️ Select unit bus langsung ke state
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
            idKoridor: 0,
            idBus: 0,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0,
            long: 0,
            lat: 0,
          );

      emit(
        state.copyWith(
          checkinData: currentCheckin.copyWith(
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

    on<SelectKoridor>((event, emit) async {
      final currentCheckin =
          state.checkinData ??
          TimetableCheckin(
            tanggal: DateTime.now().toString().split(' ')[0],
            idKoridor: 0,
            idBus: 0,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0,
            long: 0,
            lat: 0,
          );

      emit(
        state.copyWith(
          status: TimetableStatus.fetching,
          checkinData: currentCheckin.copyWith(
            ritaseKe: 0.0,
            idBus: 0,
            idKoridor: event.id,
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
            idKoridor: 0,
            idBus: 0,
            idShift: 1,
            idPramugara: 0,
            ritaseKe: 0,
            long: 0,
            lat: 0,
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
                ritaseKe: ritaseValue,
                idBus: event.id,
                idKoridor: state.idKoridor,
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
            long: 0,
            lat: 0,
          );

      emit(
        state.copyWith(
          status: TimetableStatus.success,
          idKoridor: 0,
          namaKoridor: '',
          idBus: 0,
          referenceBus: const [],
          checkinData: currentCheckin.copyWith(
            ritaseKe: 0.0,
            idBus: 0,
            idKoridor: 0,
          ),
        ),
      );
    });
  }
}
