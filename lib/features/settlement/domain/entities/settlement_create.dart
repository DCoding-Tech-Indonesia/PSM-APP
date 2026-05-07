import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';

class SettlementCreate {
  final String? processId;
  final int? auditTrailId;
  final int idBus;
  final String? code;
  final int idKoridor;
  final int idShift;
  final List<SettlementDetail> detail;
  final List<SettlementDocument> document;

  SettlementCreate({
    this.processId,
    this.auditTrailId,
    required this.idBus,
    this.code,
    required this.idKoridor,
    required this.idShift,
    required this.detail,
    required this.document,
  });

  Map<String, dynamic> toJson() => {
    "processId": processId,
    "auditTrailId": auditTrailId,
    "idBus": idBus,
    "code": code,
    "idKoridor": idKoridor,
    "idShift": idShift,
    "detail": detail.map((e) => e.toJson()).toList(),
    "document": document.map((e) => e.toJson()).toList(),
  };
}
