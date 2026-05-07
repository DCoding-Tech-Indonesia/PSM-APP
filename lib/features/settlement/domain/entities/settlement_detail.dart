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

  Map<String, dynamic> toJson() => {
    "idPayment": idPayment,
    "idNasabah": idNasabah,
    "total": total,
    "value": value,
  };

  @override
  List<Object?> get props => [idPayment, idNasabah, total, value];
}
