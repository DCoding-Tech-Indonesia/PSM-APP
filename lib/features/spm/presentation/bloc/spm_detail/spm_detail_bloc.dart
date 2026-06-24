import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/spm/data/models/spm_detail_model.dart';
import 'package:psm_mobile/features/spm/domain/repositories/spm_repository.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_detail/spm_detail_event.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_detail/spm_detail_state.dart';

class SpmDetailBloc extends Bloc<SpmDetailEvent, SpmDetailState> {
  final SpmRepository repository;

  SpmDetailBloc({required this.repository}) : super(SpmDetailInitial()) {
    on<LoadSpmDetail>(_onLoadSpmDetail);
    on<SubmitSpmData>(_onSubmitSpmData);
  }

  Future<void> _onLoadSpmDetail(
    LoadSpmDetail event,
    Emitter<SpmDetailState> emit,
  ) async {
    emit(SpmDetailLoading());
    try {
      final result = await repository.getSpmDetail(event.id);
      emit(SpmDetailLoaded(data: result));
    } catch (e) {
      emit(SpmDetailError(message: e.toString()));
    }
  }

  Future<void> _onSubmitSpmData(
    SubmitSpmData event,
    Emitter<SpmDetailState> emit,
  ) async {
    final List<SpmDetailModel> currentState = state is SpmDetailLoaded
        ? (state as SpmDetailLoaded).data
        : <SpmDetailModel>[];
    emit(SpmSubmitLoading());
    try {
      await repository.submitSpmData(
        event.idAuditTrail,
        event.reason,
      );
      emit(const SpmSubmitSuccess('Berhasil submit data SPM'));
    } catch (e) {
      emit(SpmSubmitError(e.toString()));
      if (currentState.isNotEmpty) {
        emit(SpmDetailLoaded(data: currentState));
      }
    }
  }
}
