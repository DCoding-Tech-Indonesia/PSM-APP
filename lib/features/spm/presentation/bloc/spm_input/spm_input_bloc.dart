import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/spm/domain/repositories/spm_repository.dart';
import 'spm_input_event.dart';
import 'spm_input_state.dart';

class SpmInputBloc extends Bloc<SpmInputEvent, SpmInputState> {
  final SpmRepository repository;

  SpmInputBloc({required this.repository}) : super(SpmInputInitial()) {
    on<FetchQuestions>(_onFetchQuestions);
    on<CreateSpmData>(_onCreateSpmData);
    on<SubmitSpmCreated>(_onSubmitSpmCreated);
  }

  Future<void> _onFetchQuestions(
    FetchQuestions event,
    Emitter<SpmInputState> emit,
  ) async {
    emit(QuestionsLoading());
    try {
      final questions = await repository.getSpmQuestions(
        event.idTypePemeriksaan,
      );
      emit(QuestionsLoaded(questions));
    } catch (e) {
      emit(QuestionsError(e.toString()));
    }
  }

  Future<void> _onCreateSpmData(
    CreateSpmData event,
    Emitter<SpmInputState> emit,
  ) async {
    emit(SpmCreateLoading());
    try {
      final auditTrailId = await repository.createSpm(event.payload);
      emit(SpmCreateSuccess(auditTrailId));
    } catch (e) {
      emit(SpmCreateError(e.toString()));
    }
  }

  Future<void> _onSubmitSpmCreated(
    SubmitSpmCreated event,
    Emitter<SpmInputState> emit,
  ) async {
    emit(SpmSubmitLoading());
    try {
      await repository.submitSpmData([event.idAuditTrail], event.reason);
      emit(const SpmSubmitSuccess('Data SPM berhasil disubmit.'));
    } catch (e) {
      emit(SpmSubmitError(e.toString()));
    }
  }

}
