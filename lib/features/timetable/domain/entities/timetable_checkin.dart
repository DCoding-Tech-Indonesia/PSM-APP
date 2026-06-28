import 'package:equatable/equatable.dart';

class TimetableCheckin extends Equatable {
  final String tanggal;
  final int idKoridor;
  final int idBus;
  final int idShift;
  final int idPramugara;
  final double ritaseKe;
  final double long;
  final double lat;

  const TimetableCheckin({
    required this.tanggal,
    required this.idKoridor,
    required this.idBus,
    required this.idShift,
    required this.idPramugara,
    required this.ritaseKe,
    required this.long,
    required this.lat,
  });

  bool get isSubmittable {
    return idKoridor > 0 &&
        idBus > 0 &&
        idPramugara > 0 &&
        ritaseKe > 0 &&
        long != 0.0 &&
        lat != 0.0;
  }

  String? get validationErrorMessage {
    if (idKoridor <= 0) return "Koridor belum dipilih.";
    if (idBus <= 0) return "Bus belum dipilih.";
    if (idPramugara <= 0) return "Pramugara belum dipilih.";
    if (ritaseKe <= 0) return "Ritase harus lebih dari 0.";
    if (long == 0.0 || lat == 0.0) return "Lokasi GPS belum terdeteksi.";
    return null;
  }

  factory TimetableCheckin.fromJson(Map<String, dynamic> json) {
    return TimetableCheckin(
      tanggal: json['tanggal'] ?? 0,
      idKoridor: json['idKoridor'] ?? 0,
      idBus: json['idBus'] ?? 0,
      idShift: json['idShift'] ?? 0,
      idPramugara: json['idPramugara'] ?? 0,
      ritaseKe: (json['ritaseKe'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
      lat: (json['lat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal": tanggal,
    "idKoridor": idKoridor,
    "idBus": idBus,
    "idShift": idShift,
    "idPramugara": idPramugara,
    "ritaseKe": ritaseKe,
    "long": long,
    "lat": lat,
  };

  TimetableCheckin copyWith({
    String? tanggal,
    int? idKoridor,
    int? idBus,
    int? idShift,
    int? idPramugara,
    double? ritaseKe,
    double? long,
    double? lat,
  }) {
    return TimetableCheckin(
      tanggal: tanggal ?? this.tanggal,
      idKoridor: idKoridor ?? this.idKoridor,
      idBus: idBus ?? this.idBus,
      idShift: idShift ?? this.idShift,
      idPramugara: idPramugara ?? this.idPramugara,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      long: long ?? this.long,
      lat: lat ?? this.lat,
    );
  }

  @override
  List<Object?> get props => [
    idKoridor,
    idBus,
    idPramugara,
    ritaseKe,
    long,
    lat,
  ];
}