import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/timetable/domain/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_state.dart';
import 'package:psm_mobile/features/timetable/presentation/domain/timetable_repository.dart';

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

        final currentCheckin = state.checkinData ??
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

        final updatedCheckinWithPramugara = currentCheckin.copyWith(
          idPramugara: userId,
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

        emit(
          state.copyWith(
            listTimetable: timeTableList,
            referenceKoridor: koridorList,
            checkinData: updatedCheckinWithPramugara,
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
      final currentCheckin = state.checkinData ??
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
                status: data != null ? TimetableStatus.successSave : TimetableStatus.failedSave,
                message: data != null ? "Berhasil check-in!" : "Gagal check-in!",
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
      final currentCheckin = state.checkinData ??
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

      final currentCheckin = state.checkinData ??
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
  }
}
