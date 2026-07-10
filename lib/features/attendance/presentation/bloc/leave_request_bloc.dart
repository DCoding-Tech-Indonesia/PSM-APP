import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travis/features/attendance/domain/repositories/leave_request_repository.dart';
import 'package:travis/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:travis/features/attendance/presentation/bloc/leave_request_state.dart';

class LeaveRequestBloc extends Bloc<LeaveRequestEvent, LeaveRequestState> {
  final LeaveRequestRepository repository;

  LeaveRequestBloc({required this.repository}) : super(LeaveRequestInitial()) {
    on<LoadLeaveRequestList>(_onLoadLeaveRequestList);
    on<SubmitLeaveRequest>(_onSubmitLeaveRequest);
    on<LoadLeaveRequestDetail>(_onLoadLeaveRequestDetail);
    on<ApproveLeaveRequest>(_onApproveLeaveRequest);
  }

  Future<void> _onLoadLeaveRequestList(
    LoadLeaveRequestList event,
    Emitter<LeaveRequestState> emit,
  ) async {
    try {
      if (state is LeaveRequestLoaded) {
        emit(
          (state as LeaveRequestLoaded).copyWith(
            isLoading: true,
            errorMessage: null,
          ),
        );
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
        emit(
          (state as LeaveRequestLoaded).copyWith(
            isLoading: false,
            errorMessage: e.toString(),
          ),
        );
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
      emit(
        currentState.copyWith(
          isSubmitting: true,
          submitSuccess: false,
          submitError: null,
        ),
      );

      try {
        final success = await repository.submitLeaveRequest(
          userId: event.userId,
          typePengajuan: event.typePengajuan,
          tanggalMulai: event.tanggalMulai,
          tanggalSelesai: event.tanggalSelesai,
          alasan: event.alasan,
        );

        if (success) {
          emit(
            currentState.copyWith(
              isSubmitting: false,
              submitSuccess: true,
              submitError: null,
            ),
          );
          // Re-fetch the list
          add(LoadLeaveRequestList(userId: event.userId));
        } else {
          emit(
            currentState.copyWith(
              isSubmitting: false,
              submitSuccess: false,
              submitError: 'Gagal mengirim pengajuan.',
            ),
          );
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring(11);
        }
        emit(
          currentState.copyWith(
            isSubmitting: false,
            submitSuccess: false,
            submitError: errorMsg,
          ),
        );
      }
    }
  }

  Future<void> _onLoadLeaveRequestDetail(
    LoadLeaveRequestDetail event,
    Emitter<LeaveRequestState> emit,
  ) async {
    emit(LeaveRequestDetailLoading());
    try {
      final detail = await repository.getLeaveRequestDetail(id: event.id);
      if (detail != null) {
        emit(LeaveRequestDetailLoaded(leaveRequest: detail));
      } else {
        emit(LeaveRequestError(message: 'Data pengajuan tidak ditemukan'));
      }
    } catch (e) {
      emit(LeaveRequestError(message: e.toString()));
    }
  }

  Future<void> _onApproveLeaveRequest(
    ApproveLeaveRequest event,
    Emitter<LeaveRequestState> emit,
  ) async {
    final currentState = state;
    if (currentState is LeaveRequestDetailLoaded) {
      emit(currentState.copyWith(isLoading: true));
      try {
        final successMessage = await repository.approveLeaveRequest(
          pengajuanRequestId: event.pengajuanRequestId,
          approvedByUserId: event.approvedByUserId,
          approved: event.approved,
          rejectReason: event.rejectReason,
        );

        if (!isClosed && state is LeaveRequestDetailLoaded) {
          emit(
            (state as LeaveRequestDetailLoaded).copyWith(
              isLoading: false,
              isActionSuccess: true,
              actionSuccessMessage: successMessage,
            ),
          );
        }
      } catch (e) {
        if (!isClosed && state is LeaveRequestDetailLoaded) {
          emit(
            (state as LeaveRequestDetailLoaded).copyWith(
              isLoading: false,
              actionErrorMessage: e.toString(),
            ),
          );
        }
      }
    }
  }
}
