import 'package:equatable/equatable.dart';
import 'package:travis/features/spm/data/models/spm_detail_model.dart';

abstract class SpmDetailState extends Equatable {
  const SpmDetailState();

  @override
  List<Object> get props => [];
}

class SpmDetailInitial extends SpmDetailState {}

class SpmDetailLoading extends SpmDetailState {}

class SpmDetailLoaded extends SpmDetailState {
  final List<SpmDetailModel> data;

  const SpmDetailLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class SpmDetailError extends SpmDetailState {
  final String message;

  const SpmDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

class SpmSubmitLoading extends SpmDetailState {}

class SpmSubmitSuccess extends SpmDetailState {
  final String message;

  const SpmSubmitSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SpmSubmitError extends SpmDetailState {
  final String message;

  const SpmSubmitError(this.message);

  @override
  List<Object> get props => [message];
}
