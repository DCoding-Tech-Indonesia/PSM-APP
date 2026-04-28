import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/portal/domain/entities/user_profile.dart';

abstract class PortalState extends Equatable {
  const PortalState();

  @override
  List<Object?> get props => [];
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
