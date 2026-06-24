import 'package:psm_mobile/features/spm/data/models/spm_task_model.dart';

abstract class SpmListState {
  const SpmListState();
}

class SpmListInitial extends SpmListState {}

class SpmListLoading extends SpmListState {}

class SpmListLoaded extends SpmListState {
  final List<SpmTaskModel> tasks;

  const SpmListLoaded(this.tasks);
}

class SpmListError extends SpmListState {
  final String message;

  const SpmListError(this.message);
}
