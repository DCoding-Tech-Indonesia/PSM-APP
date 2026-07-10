import 'package:travis/features/kmbus/domain/entities/kmbus_document.dart';

class KmDataAfterAuditTrail {
  final String? processId;
  final int? auditTrailId;
  final bool? isSubmit;
  final int? idKm;
  final int? titikAkhir;
  final int? titikAwal;
  final double? ritaseKe;
  final List<KmbusDocument> document;
  final String? tanggalKm;

  const KmDataAfterAuditTrail({
    this.processId,
    this.auditTrailId,
    this.isSubmit,
    this.idKm,
    this.titikAkhir,
    this.titikAwal,
    this.ritaseKe,
    required this.document,
    this.tanggalKm,
  });

  factory KmDataAfterAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmDataAfterAuditTrail(
      processId: json['processId'],
      auditTrailId: json['auditTrailId'],
      isSubmit: json['isSubmit'] ?? false,
      idKm: json['idKm'],
      titikAkhir: json['titikAkhir'],
      titikAwal: json['titikAwal'],
      ritaseKe: (json['ritaseKe'] as num? ?? 0.0).toDouble(),
      tanggalKm: json['tanggalKm'],
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
      'titikAwal': titikAwal,
      'ritaseKe': ritaseKe,
      'tanggalKm': tanggalKm,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }
}
