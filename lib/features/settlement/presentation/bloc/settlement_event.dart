import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';

abstract class SettlementEvent {}

class PageDashboardLoad extends SettlementEvent {}

class PageInputLoad extends SettlementEvent {}

class SelectBus extends SettlementEvent {
  final int id;
  final String noUnit;

  SelectBus(this.id, this.noUnit);
}

class SelectKoridor extends SettlementEvent {
  final int id;
  final String namaKoridor;

  SelectKoridor(this.id, this.namaKoridor);
}

class MoveStepWizard extends SettlementEvent {
  final int value;

  MoveStepWizard(this.value);
}

class SettlementFieldChanged extends SettlementEvent {
  final String field;
  final dynamic value;

  SettlementFieldChanged(this.field, this.value);
}

class AddDetail extends SettlementEvent {
  final SettlementDetail detail;

  AddDetail(this.detail);
}

class UpdateDetail extends SettlementEvent {
  final int idPayment;
  final int idNasabah;
  final int? total;
  final int? value;

  UpdateDetail({
    required this.idPayment,
    required this.idNasabah,
    this.total,
    this.value,
  });
}

class RemoveDetail extends SettlementEvent {
  final SettlementDetail detail;

  RemoveDetail(this.detail);
}

class AddDocument extends SettlementEvent {
  final SettlementDocument document;

  AddDocument(this.document);
}

class RemoveDocument extends SettlementEvent {
  final SettlementDocument document;

  RemoveDocument(this.document);
}

class SubmitSettlement extends SettlementEvent {}

class SubmitWorkflow extends SettlementEvent {
  final String reason;

  SubmitWorkflow(this.reason);
}