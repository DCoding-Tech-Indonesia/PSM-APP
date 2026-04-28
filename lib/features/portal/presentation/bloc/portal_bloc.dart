import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/portal/domain/repositories/portal_repository.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_event.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class PortalBloc extends Bloc<PortalEvent, PortalState> {
  final PortalRepository repository;

  PortalBloc({required this.repository}) : super(PortalInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(PortalLoading());
      final result = await repository.getProfile();
      result.fold(
        (failure) => emit(PortalError(message: failure.message)),
        (profile) => emit(PortalLoaded(profile: profile)),
      );
    });
  }
}
