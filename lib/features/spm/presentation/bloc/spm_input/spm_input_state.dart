import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';

abstract class SpmInputState {
  const SpmInputState();
}

class SpmInputInitial extends SpmInputState {}

class QuestionsLoading extends SpmInputState {}

class QuestionsLoaded extends SpmInputState {
  final List<SpmQuestionModel> questions;

  const QuestionsLoaded(this.questions);
}

class QuestionsError extends SpmInputState {
  final String message;

  const QuestionsError(this.message);
}

// --- States untuk Create SPM (/pemeriksaan-spm/create) ---
class SpmCreateLoading extends SpmInputState {}

class SpmCreateSuccess extends SpmInputState {
  final int auditTrailId;

  const SpmCreateSuccess(this.auditTrailId);
}

class SpmCreateError extends SpmInputState {
  final String message;

  const SpmCreateError(this.message);
}

// --- States untuk Submit SPM (/workflow/submit) ---
class SpmSubmitLoading extends SpmInputState {}

class SpmSubmitSuccess extends SpmInputState {
  final String message;

  const SpmSubmitSuccess(this.message);
}

class SpmSubmitError extends SpmInputState {
  final String message;

  const SpmSubmitError(this.message);
}

