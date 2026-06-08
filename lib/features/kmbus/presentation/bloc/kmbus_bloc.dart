import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/kmbus/domain/repositories/kmbus_repository.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_event.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';

class KmbusBloc extends Bloc<KmbusEvent, KmbusState> {
  final KmbusRepository kmbusRepository;

  KmbusBloc(this.kmbusRepository) : super(const KmbusState()) {
    on<KmbusTitikAwalInputLoad>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.initial));

      try {
        final resultKoridor = await kmbusRepository.fetchReferenceKoridor('');

        final koridorList = resultKoridor.fold((failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
          return null;
        }, (data) => data);

        emit(
          state.copyWith(
            status: KmbusStatus.success,
            referenceKoridor: koridorList,
          ),
        );
      } catch (e, s) {
        debugPrint(e.toString());
        debugPrint(s.toString());

        emit(state.copyWith(status: KmbusStatus.error, message: e.toString()));
      }
    });

    on<UploadOcrEvent>((event, emit) async {
      emit(state.copyWith(uploadStatus: UploadStatus.uploading));

      final result = await kmbusRepository.uploadOcr(event.file);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              uploadStatus: UploadStatus.errorOcr,
              message: failure.message,
            ),
          );
        },
        (ocrValue) {
          if (ocrValue.isEmpty) {
            emit(state.copyWith(uploadStatus: UploadStatus.errorOcr));
            return;
          }

          final km = int.tryParse(ocrValue);

          if (km == null) {
            emit(
              state.copyWith(
                uploadStatus: UploadStatus.errorOcr,
                message: 'OCR bukan angka valid',
              ),
            );
            return;
          }

          emit(
            state.copyWith(
              uploadStatus: UploadStatus.successOcr,
              ocrResult: ocrValue,
              speedometerImage: event.file,
              titikAwalCreate: state.titikAwalCreate?.copyWith(titikAwal: km),
            ),
          );
        },
      );
    });

    // REFERENCE HANDLER
    on<SelectKoridor>((event, emit) async {
      emit(state.copyWith(status: KmbusStatus.fetching, idKoridor: event.id));
      final resultBus = await kmbusRepository.fetchReferenceBus('', event.id);
      resultBus.fold(
        (failure) {
          emit(
            state.copyWith(status: KmbusStatus.error, message: failure.message),
          );
        },
        (data) {
          emit(state.copyWith(status: KmbusStatus.success, referenceBus: data));
        },
      );
    });
  }
}
