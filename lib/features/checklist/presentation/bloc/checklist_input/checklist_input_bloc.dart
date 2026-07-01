import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/checklist/domain/repositories/checklist_repository.dart';
import 'checklist_input_event.dart';
import 'checklist_input_state.dart';

class ChecklistInputBloc
    extends Bloc<ChecklistInputEvent, ChecklistInputState> {
  final ChecklistRepository repository;

  ChecklistInputBloc({required this.repository})
    : super(ChecklistInputInitial()) {
    on<LoadChecklistQuestions>(_onLoadChecklistQuestions);
    on<SubmitChecklist>(_onSubmitChecklist);
  }

  Future<void> _onLoadChecklistQuestions(
    LoadChecklistQuestions event,
    Emitter<ChecklistInputState> emit,
  ) async {
    emit(ChecklistQuestionsLoading());
    try {
      final questions = await repository.getChecklistQuestions(
        tipeForm: event.tipeForm,
      );
      emit(ChecklistQuestionsLoaded(questions));
    } catch (e) {
      emit(ChecklistQuestionsError(e.toString()));
    }
  }

  Future<void> _onSubmitChecklist(
    SubmitChecklist event,
    Emitter<ChecklistInputState> emit,
  ) async {
    emit(ChecklistSubmitting());
    try {
      final msg = await repository.createChecklist(event.payload);
      emit(ChecklistSubmitSuccess(msg)); // Kirim message ke UI
    } catch (e) {
      emit(ChecklistSubmitError(e.toString()));
    }
  }
}
