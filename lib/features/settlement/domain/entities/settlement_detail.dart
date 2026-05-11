import 'package:equatable/equatable.dart';

class SettlementDetail extends Equatable{
  final int idPayment;
  final int idNasabah;
  final int total;
  final int value;

  SettlementDetail({
    required this.idPayment,
    required this.idNasabah,
    required this.total,
    required this.value,
  });

  factory SettlementDetail.fromJson(Map<String, dynamic> json) {
    return SettlementDetail(
      idPayment: json['idPayment'] ?? 0,
      idNasabah: json['idNasabah'] ?? 0,
      total: json['total'] ?? 0,
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "idPayment": idPayment,
    "idNasabah": idNasabah,
    "total": total,
    "value": value,
  };

  @override
  List<Object?> get props => [idPayment, idNasabah, total, value];
}
