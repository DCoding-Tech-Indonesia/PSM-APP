import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_document.dart';

class TitikAwalCreate {
  final bool isSubmit;
  final String tanggalKm;
  final int idKoridor;
  final int idShift;
  final int idBus;
  final int idPramugara;
  final double ritaseKe;
  final int titikAwal;
  final String? keteranganBus;
  final List<KmbusDocument> document;

  TitikAwalCreate({
    required this.isSubmit,
    required this.tanggalKm,
    required this.idKoridor,
    required this.idShift,
    required this.idBus,
    required this.idPramugara,
    required this.ritaseKe,
    required this.titikAwal,
    this.keteranganBus,
    required this.document,
  });

  TitikAwalCreate copyWith({
    bool? isSubmit,
    String? tanggalKm,
    int? idKoridor,
    int? idShift,
    int? idBus,
    int? idPramugara,
    double? ritaseKe,
    int? titikAwal,
    String? keteranganBus,
    List<KmbusDocument>? document,
  }) {
    return TitikAwalCreate(
      isSubmit: isSubmit ?? this.isSubmit,
      tanggalKm: tanggalKm ?? this.tanggalKm,
      idKoridor: idKoridor ?? this.idKoridor,
      idShift: idShift ?? this.idShift,
      idBus: idBus ?? this.idBus,
      idPramugara: idPramugara ?? this.idPramugara,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      titikAwal: titikAwal ?? this.titikAwal,
      keteranganBus: keteranganBus ?? this.keteranganBus,
      document: document ?? this.document,
    );
  }

  factory TitikAwalCreate.fromJson(Map<String, dynamic> json) {
    return TitikAwalCreate(
      isSubmit: json['isSubmit'],
      tanggalKm: json['tanggalKm'],
      idKoridor: json['idKoridor'],
      idShift: json['idShift'],
      idBus: json['idBus'],
      idPramugara: json['idPramugara'],
      ritaseKe: json['ritaseKe'],
      titikAwal: json['titikAwal'],
      keteranganBus: json['keteranganBus'],
      document: (json['document'] as List<dynamic>? ?? [])
          .map((e) => KmbusDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isSubmit': isSubmit,
      'tanggalKm': tanggalKm,
      'idKoridor': idKoridor,
      'idShift': idShift,
      'idBus': idBus,
      'idPramugara': idPramugara,
      'ritaseKe': ritaseKe,
      'titikAwal': titikAwal,
      'keteranganBus': keteranganBus,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'isSubmit': isSubmit,
      'tanggalKm': tanggalKm,
      'idKoridor': idKoridor,
      'idShift': idShift,
      'idBus': idBus,
      'idPramugara': idPramugara,
      'ritaseKe': ritaseKe,
      'titikAwal': titikAwal,
      'keteranganBus': keteranganBus,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }
}
