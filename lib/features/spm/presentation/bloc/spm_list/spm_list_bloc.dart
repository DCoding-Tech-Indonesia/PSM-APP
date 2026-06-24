import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/spm/domain/repositories/spm_repository.dart';
import 'spm_list_event.dart';
import 'spm_list_state.dart';

class SpmListBloc extends Bloc<SpmListEvent, SpmListState> {
  final SpmRepository repository;

  SpmListBloc({required this.repository}) : super(SpmListInitial()) {
    on<LoadSpmList>(_onLoadSpmList);
  }

  Future<void> _onLoadSpmList(LoadSpmList event, Emitter<SpmListState> emit) async {
    emit(SpmListLoading());
    try {
      final tasks = await repository.getSpmList(
        keyword: event.keyword,
        page: event.page,
        perPage: event.perPage,
      );
      emit(SpmListLoaded(tasks));
    } catch (e) {
      emit(SpmListError(e.toString()));
    }
  }
}
