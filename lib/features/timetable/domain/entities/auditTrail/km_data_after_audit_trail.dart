class KmDataAfterAuditTrail {
  final String? processId;
  final int? auditTrailId;
  final bool isSubmit;
  final String? code;
  final String tanggalKm;
  final int idKoridor;
  final int idShift;
  final int idBus;
  final int idPramugara;
  final double? ritaseKe;
  final int? titikAwal;
  final int? titikAkhir;
  final String? keteranganBus;
  final List<KmTaskDocument> document;

  const KmDataAfterAuditTrail({
    this.processId,
    this.auditTrailId,
    required this.isSubmit,
    this.code,
    required this.tanggalKm,
    required this.idKoridor,
    required this.idShift,
    required this.idBus,
    required this.idPramugara,
    this.ritaseKe,
    this.titikAwal,
    this.titikAkhir,
    this.keteranganBus,
    required this.document,
  });

  factory KmDataAfterAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmDataAfterAuditTrail(
      processId: json['processId'],
      auditTrailId: json['auditTrailId'],
      isSubmit: json['isSubmit'] ?? false,
      code: json['code'],
      tanggalKm: json['tanggalKm'] ?? '',
      idKoridor: json['idKoridor'] ?? 0,
      idShift: json['idShift'] ?? 0,
      idBus: json['idBus'] ?? 0,
      idPramugara: json['idPramugara'] ?? 0,
      ritaseKe: json['ritaseKe'],
      titikAwal: json['titikAwal'] ?? 0,
      titikAkhir: json['titikAkhir'] ?? 0,
      keteranganBus: json['keteranganBus'],
      document: (json['document'] as List<dynamic>? ?? [])
          .map((e) => KmTaskDocument.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'processId': processId,
    'auditTrailId': auditTrailId,
    'isSubmit': isSubmit,
    'code': code,
    'tanggalKm': tanggalKm,
    'idKoridor': idKoridor,
    'idShift': idShift,
    'idBus': idBus,
    'idPramugara': idPramugara,
    'ritaseKe': ritaseKe,
    'titikAwal': titikAwal,
    'titikAkhir': titikAkhir,
    'keteranganBus': keteranganBus,
    'document': document.map((e) => e.toJson()).toList(),
  };
}

class KmTaskDocument {
  final int? idKmDocument;
  final int? idDocument;
  final int? idDocumentType;

  const KmTaskDocument({
    this.idKmDocument,
    this.idDocument,
    this.idDocumentType,
  });

  factory KmTaskDocument.fromJson(Map<String, dynamic> json) {
    return KmTaskDocument(
      idKmDocument: json['idKmDocument'],
      idDocument: json['idDocument'],
      idDocumentType: json['idDocumentType'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idKmDocument': idKmDocument,
    'idDocument': idDocument,
    'idDocumentType': idDocumentType,
  };
}