import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travis/features/checklist/domain/repositories/checklist_repository.dart';
import 'checklist_list_event.dart';
import 'checklist_list_state.dart';

class ChecklistListBloc extends Bloc<ChecklistListEvent, ChecklistListState> {
  final ChecklistRepository repository;

  ChecklistListBloc({required this.repository})
      : super(ChecklistListInitial()) {
    on<LoadChecklistList>(_onLoadChecklistList);
  }

  Future<void> _onLoadChecklistList(
    LoadChecklistList event,
    Emitter<ChecklistListState> emit,
  ) async {
    emit(ChecklistListLoading());
    try {
      final items = await repository.getChecklistList(
        keyword: event.keyword,
        page: event.page,
        perPage: event.perPage,
      );
      emit(ChecklistListLoaded(items));
    } catch (e) {
      emit(ChecklistListError(e.toString()));
    }
  }
}
