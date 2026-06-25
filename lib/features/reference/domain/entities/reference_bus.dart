import 'package:equatable/equatable.dart';

class ReferenceBus extends Equatable {
  final int? id;
  final String nomorLambung;
  final String platNomor;

  const ReferenceBus({
    this.id,
    required this.nomorLambung,
    required this.platNomor,
  });

  factory ReferenceBus.fromJson(Map<String, dynamic> json) {
    return ReferenceBus(
      id: json['id'],
      nomorLambung: json['nomorLambung'] ?? '',
      platNomor: json['platNomor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorLambung": nomorLambung,
    "platNomor": platNomor,
  };

  ReferenceBus copyWith({
    int? id,
    String? nomorLambung,
    String? platNomor,
  }) {
    return ReferenceBus(
      id: id ?? this.id,
      nomorLambung: nomorLambung ?? this.nomorLambung,
      platNomor: platNomor ?? this.platNomor,
    );
  }

  @override
  List<Object?> get props => [id, nomorLambung, platNomor];
}