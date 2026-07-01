import 'package:psm_mobile/features/checklist/data/models/checklist_question_model.dart';

abstract class ChecklistInputState {
  const ChecklistInputState();
}

class ChecklistInputInitial extends ChecklistInputState {}

class ChecklistQuestionsLoading extends ChecklistInputState {}

class ChecklistQuestionsLoaded extends ChecklistInputState {
  final List<ChecklistQuestionModel> questions;

  const ChecklistQuestionsLoaded(this.questions);
}

class ChecklistQuestionsError extends ChecklistInputState {
  final String message;

  const ChecklistQuestionsError(this.message);
}

class ChecklistSubmitting extends ChecklistInputState {}

class ChecklistSubmitSuccess extends ChecklistInputState {
  final String message;

  const ChecklistSubmitSuccess(this.message);
}

class ChecklistSubmitError extends ChecklistInputState {
  final String message;

  const ChecklistSubmitError(this.message);
}
