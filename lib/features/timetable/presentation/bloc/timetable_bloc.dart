import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:collection/collection.dart';
import 'package:psm_mobile/core/error/failure.dart';
import 'package:psm_mobile/core/presentations/entity/core_data_source_response.dart';
import 'package:psm_mobile/features/reference/domain/entities/next_ritase_response.dart';
import 'package:psm_mobile/core/presentations/entity/core_schedule_model.dart';
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

        // Run independent calls in parallel (Step 1)
        final resultsStep1 = await Future.wait([
          timetableRepository.fetchListTimeTable(''),
          timetableRepository.fetchKmbusDataToday(''),
          timetableRepository.checkAbsenceExist(state.long, state.lat),
          if (userId != 0) timetableRepository.fetchTodaySchedule(userId),
        ]);

        final listResult = resultsStep1[0] as Either<Failure, List<TimetableData>>;
        final listMasterResult = resultsStep1[1] as Either<Failure, List<KmbusData>>;
        final isAlreadyTakeAttendanceResult = resultsStep1[2] as Either<Failure, bool?>;
        final todayScheduleResult = userId != 0 ? resultsStep1[3] as Either<Failure, List<CoreScheduleModel>> : null;

        final timeTableList = listResult.fold((_) => null, (data) => data);
        timeTableList?.sort((a, b) {
          final jamA = a.jamBerangkat.trim().isEmpty ? '00:00:00' : a.jamBerangkat.split('.').first;
          final jamB = b.jamBerangkat.trim().isEmpty ? '00:00:00' : b.jamBerangkat.split('.').first;
          final dateTimeA = DateTime.parse('${a.tanggal} $jamA');
          final dateTimeB = DateTime.parse('${b.tanggal} $jamB');
          return dateTimeB.compareTo(dateTimeA);
        });

        emit(state.copyWith(listTimetable: timeTableList));

        if (todayScheduleResult == null) {
          emit(state.copyWith(status: TimetableStatus.error, message: "Jadwal tidak ditemukan", jadwalExist: false));
          return;
        }

        final todayScheduleData = todayScheduleResult.fold(
          (failure) {
            emit(state.copyWith(status: TimetableStatus.error, message: failure.message));
            return null;
          },
          (data) => data,
        );

        if (todayScheduleData == null || todayScheduleData.isEmpty) {
          emit(state.copyWith(status: TimetableStatus.error, message: "Jadwal tidak ditemukan", jadwalExist: false));
          return;
        }

        final idKoridorShift = todayScheduleData[0].lokasi.koridor;
        final namaKoridorShift = todayScheduleData[0].lokasi.namaLokasi;
        final idBusShift = todayScheduleData[0].bus.id;
        final idShiftActive = todayScheduleData[0].shift.id;
        final currentNoUnit = todayScheduleData[0].bus.nomorLambung;

        // Fetch Next Ritase (Step 2)
        final nextRitaseResult = await timetableRepository.fetchNextRitase(idKoridorShift, idBusShift!);

        final double ritaseValue = nextRitaseResult.fold((_) => 0.0, (value) => value.ritaseKe!);
        final bool isLastRitase = nextRitaseResult.fold((_) => false, (value) => value.isLastRitase!);

        // Run checks and verify check-in/out allow states in parallel (Step 3)
        final checkResults = await Future.wait([
          timetableRepository.checkAllowCheckIn(idKoridorShift, idBusShift, ritaseValue),
          timetableRepository.checkAllowCheckOut(idKoridorShift, idBusShift, ritaseValue),
        ]);

        final checkInAllowResult = checkResults[0] as Either<Failure, CoreDataSourceResponse>;
        final checkOutAllowResult = checkResults[1] as Either<Failure, CoreDataSourceResponse>;

        final bool isAllowCheckIn = checkInAllowResult.fold((_) => false, (res) => res.isAllowed);
        final String checkInMessage = checkInAllowResult.fold((_) => '', (res) => res.message);
        final bool isAllowCheckOut = checkOutAllowResult.fold((_) => false, (res) => res.isAllowed);
        final String checkOutMessage = checkOutAllowResult.fold((_) => '', (res) => res.message);

        final kmBusListMaster = listMasterResult.fold((_) => null, (data) => data);
        final activeMasterData = kmBusListMaster?.firstWhereOrNull(
          (e) => e.titikAkhir == null,
        );
        final idKm = activeMasterData?.id ?? 0;

        final bool? isAlreadyTakeAttendanceRestule = isAlreadyTakeAttendanceResult.fold(
          (failure) {
            emit(state.copyWith(status: TimetableStatus.error, message: failure.message));
            return null;
          },
          (data) => data ?? false,
        );

        if (isAlreadyTakeAttendanceRestule == null) return;

        final activeCheckin = timeTableList?.firstWhereOrNull(
          (e) => e.jamDatang.trim().isEmpty,
        );
        final int? idCheckin = activeCheckin?.id;

        final currentCheckin = state.checkinData ?? TimetableCheckin(
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

        final bool isLastRitaseCompleted = isLastRitase &&
            (timeTableList?.any((e) => e.ritaseKe == ritaseValue && e.jamDatang.trim().isNotEmpty) ?? false);

        emit(
          state.copyWith(
            isLastRitase: isLastRitase,
            idShift: idShiftActive,
            idKm: idKm,
            ritaseKe: ritaseValue,
            idCheckin: idCheckin,
            checkinData: updatedCheckinWithPramugara,
            idKoridor: idKoridorShift,
            namaKoridor: namaKoridorShift,
            idBus: idBusShift,
            noUnit: currentNoUnit,
            isAllowCheckIn: !isLastRitaseCompleted && isAllowCheckIn && isAlreadyTakeAttendanceRestule,
            isAllowCheckOut: isAllowCheckOut,
            disabledBerangkatMessage: isLastRitaseCompleted
                ? "Semua ritase hari ini telah diselesaikan."
                : (!isAlreadyTakeAttendanceRestule ? "Harap ambil absensi terlebih dahulu." : checkInMessage),
            disabledDatangMessage: checkOutMessage,
            status: TimetableStatus.success,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());
        emit(state.copyWith(status: TimetableStatus.error, message: e.toString()));
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
