import 'package:travis/features/settlement/domain/entities/settlement_detail.dart';
import 'package:travis/features/settlement/domain/entities/settlement_document.dart';

class SettlementCreate {
  final bool? isSubmit;
  final String? processId;
  final int? auditTrailId;
  final int idKoridor;
  final int idShift;
  final double? ritaseKe;
  final List<SettlementDetail> detail;
  final List<SettlementDocument> document;

  SettlementCreate({
    required this.isSubmit,
    this.processId,
    this.auditTrailId,
    required this.idKoridor,
    required this.idShift,
    this.ritaseKe,
    required this.detail,
    required this.document,
  });

  factory SettlementCreate.fromJson(Map<String, dynamic> json) {
    return SettlementCreate(
      isSubmit: json['isSubmit'],
      processId: json['processId'],
      auditTrailId: json['auditTrailId'],
      idKoridor: json['idKoridor'] ?? 0,
      idShift: json['idShift'] ?? 0,
      ritaseKe: (json['ritaseKe'] as num?)?.toDouble(),
      detail: (json['detail'] as List<dynamic>? ?? [])
          .map((e) => SettlementDetail.fromJson(e))
          .toList(),
      document: (json['document'] as List<dynamic>? ?? [])
          .map((e) => SettlementDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "isSubmit": isSubmit,
    "processId": processId,
    "auditTrailId": auditTrailId,
    "idKoridor": idKoridor,
    "idShift": idShift,
    "ritaseKe": ritaseKe,
    "detail": detail.map((e) => e.toJson()).toList(),
    "document": document.map((e) => e.toJson()).toList(),
  };
}
