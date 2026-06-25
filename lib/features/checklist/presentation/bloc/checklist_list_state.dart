import 'package:psm_mobile/features/checklist/data/models/checklist_item_model.dart';

abstract class ChecklistListState {
  const ChecklistListState();
}

class ChecklistListInitial extends ChecklistListState {}

class ChecklistListLoading extends ChecklistListState {}

class ChecklistListLoaded extends ChecklistListState {
  final List<ChecklistItemModel> items;

  const ChecklistListLoaded(this.items);
}

class ChecklistListError extends ChecklistListState {
  final String message;

  const ChecklistListError(this.message);
}
