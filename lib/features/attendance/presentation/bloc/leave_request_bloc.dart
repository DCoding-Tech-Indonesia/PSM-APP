import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/leave_request_repository.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_state.dart';

class LeaveRequestBloc extends Bloc<LeaveRequestEvent, LeaveRequestState> {
  final LeaveRequestRepository repository;

  LeaveRequestBloc({required this.repository}) : super(LeaveRequestInitial()) {
    on<LoadLeaveRequestList>(_onLoadLeaveRequestList);
    on<SubmitLeaveRequest>(_onSubmitLeaveRequest);
  }

  Future<void> _onLoadLeaveRequestList(
    LoadLeaveRequestList event,
    Emitter<LeaveRequestState> emit,
  ) async {
    try {
      if (state is LeaveRequestLoaded) {
        emit((state as LeaveRequestLoaded).copyWith(isLoading: true, errorMessage: null));
      } else {
        emit(LeaveRequestLoading());
      }

      final leaveRequests = await repository.getLeaveRequestList(
        page: event.page,
        perPage: event.perPage,
        status: event.status,
        type: event.type,
        userId: event.userId,
        keyword: event.keyword,
      );

      emit(LeaveRequestLoaded(leaveRequests: leaveRequests, isLoading: false));
    } catch (e) {
      if (state is LeaveRequestLoaded) {
        emit((state as LeaveRequestLoaded).copyWith(isLoading: false, errorMessage: e.toString()));
      } else {
        emit(LeaveRequestError(message: e.toString()));
      }
    }
  }

  Future<void> _onSubmitLeaveRequest(
    SubmitLeaveRequest event,
    Emitter<LeaveRequestState> emit,
  ) async {
    if (state is LeaveRequestLoaded) {
      final currentState = state as LeaveRequestLoaded;
      
      // Emit submitting state
      emit(currentState.copyWith(isSubmitting: true, submitSuccess: false, submitError: null));

      try {
        final success = await repository.submitLeaveRequest(
          userId: event.userId,
          typePengajuan: event.typePengajuan,
          tanggalMulai: event.tanggalMulai,
          tanggalSelesai: event.tanggalSelesai,
          alasan: event.alasan,
        );

        if (success) {
          emit(currentState.copyWith(isSubmitting: false, submitSuccess: true, submitError: null));
          // Re-fetch the list
          add(LoadLeaveRequestList(userId: event.userId));
        } else {
          emit(currentState.copyWith(isSubmitting: false, submitSuccess: false, submitError: 'Gagal mengirim pengajuan.'));
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring(11);
        }
        emit(currentState.copyWith(isSubmitting: false, submitSuccess: false, submitError: errorMsg));
      }
    }
  }
}
