import 'package:equatable/equatable.dart';

abstract class ApprovalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadApprovalData extends ApprovalEvent {
  LoadApprovalData();

  @override
  List<Object?> get props => [];
}

class LoadApprovalDetail extends ApprovalEvent {
  final int id;

  LoadApprovalDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class ApproveShift extends ApprovalEvent {
  final int pergantianShiftId;
  final bool approved;
  final String? rejectReason;

  ApproveShift({
    required this.pergantianShiftId,
    required this.approved,
    this.rejectReason,
  });

  @override
  List<Object?> get props => [pergantianShiftId, approved, rejectReason];
}

abstract class ApprovalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ApprovalLoaded extends ApprovalState {
  final bool isLoading;
  final List<dynamic> approvals;
  final String? errorMessage;

  ApprovalLoaded({
    required this.isLoading,
    required this.approvals,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, approvals, errorMessage];

  ApprovalLoaded copyWith({
    bool? isLoading,
    List<dynamic>? approvals,
    String? errorMessage,
  }) {
    return ApprovalLoaded(
      isLoading: isLoading ?? this.isLoading,
      approvals: approvals ?? this.approvals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ApprovalDetailLoaded extends ApprovalState {
  final dynamic detail;
  final bool isLoading;
  final String? errorMessage;
  final bool isActionSuccess;

  ApprovalDetailLoaded({
    required this.detail,
    this.isLoading = false,
    this.errorMessage,
    this.isActionSuccess = false,
  });

  @override
  List<Object?> get props => [detail, isLoading, errorMessage, isActionSuccess];

  ApprovalDetailLoaded copyWith({
    dynamic detail,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isActionSuccess,
  }) {
    return ApprovalDetailLoaded(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isActionSuccess: isActionSuccess ?? this.isActionSuccess,
    );
  }
}

class ApprovalInitial extends ApprovalState {}

class ApprovalLoading extends ApprovalState {}

class ApprovalError extends ApprovalState {
  final String message;

  ApprovalError({required this.message});

  @override
  List<Object?> get props => [message];
}
