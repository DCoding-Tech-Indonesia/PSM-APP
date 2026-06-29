import 'package:equatable/equatable.dart';

class TimetableData extends Equatable {
  final int id;
  final double ritaseKe;
  final String jamBerangkat;
  final String jamDatang;

  final String namaKoridor;
  final String nomorLambung;
  final String platNomor;
  final String tanggal;

  const TimetableData({
    required this.id,
    required this.ritaseKe,
    required this.jamBerangkat,
    required this.jamDatang,
    required this.namaKoridor,
    required this.nomorLambung,
    required this.platNomor,
    required this.tanggal,
  });

  factory TimetableData.fromJson(Map<String, dynamic> json) {
    final timeTable = json['timeTable'] as Map<String, dynamic>? ?? {};
    final bus = timeTable['bus'] as Map<String, dynamic>? ?? {};
    final koridor = timeTable['koridor'] as Map<String, dynamic>? ?? {};

    return TimetableData(
      id: json['id'] as int,
      ritaseKe: (json['ritaseKe'] as num).toDouble(),
      jamBerangkat: json['jamBerangkat']?.toString() ?? '',
      jamDatang: json['jamDatang']?.toString() ?? '',

      namaKoridor: koridor['name']?.toString() ?? '',
      nomorLambung: bus['nomorLambung']?.toString() ?? '',
      platNomor: bus['platNomor']?.toString() ?? '',
      tanggal: timeTable['tanggal']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "ritaseKe": ritaseKe,
    "jamBerangkat": jamBerangkat,
    "jamDatang": jamDatang,
    "namaKoridor": namaKoridor,
    "nomorLambung": nomorLambung,
    "platNomor": platNomor,
    "tanggal": tanggal,
  };

  TimetableData copyWith({
    int? id,
    double? ritaseKe,
    String? jamBerangkat,
    String? jamDatang,
    String? namaKoridor,
    String? nomorLambung,
    String? platNomor,
    String? tanggal,
  }) {
    return TimetableData(
      id: id ?? this.id,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      jamBerangkat: jamBerangkat ?? this.jamBerangkat,
      jamDatang: jamDatang ?? this.jamDatang,
      namaKoridor: namaKoridor ?? this.namaKoridor,
      nomorLambung: nomorLambung ?? this.nomorLambung,
      platNomor: platNomor ?? this.platNomor,
      tanggal: tanggal ?? this.tanggal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ritaseKe,
    jamBerangkat,
    jamDatang,
    namaKoridor,
    nomorLambung,
    platNomor,
    tanggal,
  ];
}