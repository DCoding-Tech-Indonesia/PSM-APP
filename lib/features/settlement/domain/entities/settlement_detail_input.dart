import 'package:equatable/equatable.dart';

class SettlementDetailInput extends Equatable {
  final int idPayment;
  final int idNasabah;
  final int value;

  const SettlementDetailInput({
    required this.idPayment,
    required this.idNasabah,
    required this.value,
  });

  factory SettlementDetailInput.fromJson(Map<String, dynamic> json) {
    return SettlementDetailInput(
      idPayment: json['idPayment'] ?? 0,
      idNasabah: json['idNasabah'] ?? 0,
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "idPayment": idPayment,
    "idNasabah": idNasabah,
    "value": value,
  };

  @override
  List<Object?> get props => [idPayment, idNasabah, value];
}