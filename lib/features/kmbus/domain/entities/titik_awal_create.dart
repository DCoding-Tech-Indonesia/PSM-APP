import 'dart:convert';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_document.dart';

class TitikAwalCreate {
  final bool isSubmit;
  final String tanggalKm;
  final int idKoridor;
  final int idShift;
  final int idBus;
  final int idPramugara;
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
      titikAwal: titikAwal ?? this.titikAwal,
      keteranganBus: keteranganBus ?? this.keteranganBus,
      document: document ?? this.document,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'isSubmit': isSubmit,
      'tanggalKm': tanggalKm,
      'idKoridor': idKoridor,
      'idShift': idShift,
      'idBus': idBus,
      'idPramugara': idPramugara,
      'titikAwal': titikAwal,
      'keteranganBus': keteranganBus,
      'document': document.map((x) => x.toJson()).toList(),
    };
  }
}