import 'package:travis/features/attendance/data/models/leave_request_model.dart';

abstract class LeaveRequestState {}

class LeaveRequestInitial extends LeaveRequestState {}

class LeaveRequestLoading extends LeaveRequestState {}

class LeaveRequestLoaded extends LeaveRequestState {
  final List<LeaveRequestModel> leaveRequests;
  final String? errorMessage;
  final bool isLoading;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  LeaveRequestLoaded({
    required this.leaveRequests,
    this.errorMessage,
    this.isLoading = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  LeaveRequestLoaded copyWith({
    List<LeaveRequestModel>? leaveRequests,
    String? errorMessage,
    bool? isLoading,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
  }) {
    return LeaveRequestLoaded(
      leaveRequests: leaveRequests ?? this.leaveRequests,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: submitError,
    );
  }
}

class LeaveRequestError extends LeaveRequestState {
  final String message;

  LeaveRequestError({required this.message});
}

class LeaveRequestDetailLoading extends LeaveRequestState {}

class LeaveRequestDetailLoaded extends LeaveRequestState {
  final LeaveRequestModel leaveRequest;
  final bool isLoading;
  final bool isActionSuccess;
  final String? actionErrorMessage;
  final String? actionSuccessMessage;

  LeaveRequestDetailLoaded({
    required this.leaveRequest,
    this.isLoading = false,
    this.isActionSuccess = false,
    this.actionErrorMessage,
    this.actionSuccessMessage,
  });

  LeaveRequestDetailLoaded copyWith({
    LeaveRequestModel? leaveRequest,
    bool? isLoading,
    bool? isActionSuccess,
    String? actionErrorMessage,
    String? actionSuccessMessage,
  }) {
    return LeaveRequestDetailLoaded(
      leaveRequest: leaveRequest ?? this.leaveRequest,
      isLoading: isLoading ?? this.isLoading,
      isActionSuccess: isActionSuccess ?? this.isActionSuccess,
      actionErrorMessage: actionErrorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }
}
