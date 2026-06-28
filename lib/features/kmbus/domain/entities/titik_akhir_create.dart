import 'dart:convert';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_document.dart';

class TitikAkhirCreate {
  final String? processId;
  final int? auditTrailId;
  final bool isSubmit;
  final int idKm;
  final int titikAkhir;
  final double ritaseKe;
  final List<KmbusDocument> document;

  TitikAkhirCreate({
    this.processId,
    this.auditTrailId,
    required this.isSubmit,
    required this.idKm,
    required this.titikAkhir,
    required this.ritaseKe,
    required this.document,
  });

  TitikAkhirCreate copyWith({
    String? processId,
    int? auditTrailId,
    bool? isSubmit,
    int? idKm,
    int? titikAkhir,
    double? ritaseKe,
    List<KmbusDocument>? document,
  }) {
    return TitikAkhirCreate(
      processId: processId ?? this.processId,
      auditTrailId: auditTrailId ?? this.auditTrailId,
      isSubmit: isSubmit ?? this.isSubmit,
      idKm: idKm ?? this.idKm,
      titikAkhir: titikAkhir ?? this.titikAkhir,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      document: document ?? this.document,
    );
  }

  factory TitikAkhirCreate.fromJson(Map<String, dynamic> json) {
    return TitikAkhirCreate(
      processId: json['processId'],
      auditTrailId: json['auditTrailId'],
      isSubmit: json['isSubmit'] ?? false,
      idKm: json['idKm'] ?? 0,
      ritaseKe: (json['ritaseKe'] as num? ?? 0.0).toDouble(),
      titikAkhir: json['titikAkhir'] ?? 0,
      document: (json['document'] as List<dynamic>? ?? [])
          .map((e) => KmbusDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processId': processId,
      'auditTrailId': auditTrailId,
      'isSubmit': isSubmit,
      'idKm': idKm,
      'titikAkhir': titikAkhir,
      'ritaseKe': ritaseKe,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'processId': processId,
      'auditTrailId': auditTrailId,
      'isSubmit': isSubmit,
      'idKm': idKm,
      'titikAkhir': titikAkhir,
      'ritaseKe': ritaseKe,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }
}