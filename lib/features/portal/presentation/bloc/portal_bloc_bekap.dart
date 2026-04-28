import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/portal/domain/repositories/portal_repository.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_event_bekap.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state_bekap.dart';

class PortalBloc extends Bloc<PortalEvent, PortalState> {
  final AuthRepository authRepository;
  final SecureStorageService secureStorageService;
  final PortalRepository portalRepository;

  PortalBloc(this.authRepository, this.secureStorageService, this.portalRepository)
    : super(const PortalState()) {
    on<PageLoad>((event, emit) async {
      final userId = await secureStorageService.readUserId();
      final username = await secureStorageService.readUsername();

      if (userId!.isNotEmpty && username!.isNotEmpty) {
        emit(state.copyWith(userId: userId, username: username));
      }
    });

    on<Logout>((event, emit) async {
      final result = await authRepository.logout(state.userId, state.username);

      result.match(
        (failure) {
          state.copyWith(logoutSuccess: false);
        },
        (response) {
          emit(state.copyWith(logoutSuccess: true));
        },
      );
    });
  }
}