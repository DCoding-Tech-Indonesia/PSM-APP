import 'package:equatable/equatable.dart';

abstract class SpmDetailEvent extends Equatable {
  const SpmDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadSpmDetail extends SpmDetailEvent {
  final int id;

  const LoadSpmDetail(this.id);

  @override
  List<Object> get props => [id];
}

class SubmitSpmData extends SpmDetailEvent {
  final List<int> idAuditTrail;
  final String reason;

  const SubmitSpmData(this.idAuditTrail, this.reason);

  @override
  List<Object> get props => [idAuditTrail, reason];
}
