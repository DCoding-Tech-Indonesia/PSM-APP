import 'package:equatable/equatable.dart';
import 'package:travis/features/portal/domain/entities/user_profile.dart';

class PortalState extends Equatable {
  final String userId;
  final String username;
  final bool logoutSuccess;

  const PortalState({
    this.userId = '',
    this.username = '',
    this.logoutSuccess = false,
  });

  PortalState copyWith({
    String? userId,
    String? username,
    bool? logoutSuccess,
  }) {
    return PortalState(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      logoutSuccess: logoutSuccess ?? this.logoutSuccess,
    );
  }

  @override
  List<Object?> get props => [userId, username, logoutSuccess];
}

class PortalInitial extends PortalState {}

class PortalLoading extends PortalState {}

class PortalLoaded extends PortalState {
  final UserProfile profile;

  const PortalLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class PortalError extends PortalState {
  final String message;

  const PortalError({required this.message});

  @override
  List<Object?> get props => [message];
}
