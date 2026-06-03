import 'package:equatable/equatable.dart';

class SettlementDetail extends Equatable {
  final int? idDetail;
  final int idBus;
  final double ritaseKe;
  final int idPayment;
  final int idNasabah;
  final int idCustomerBilling;
  final int total;
  final int value;
  final int? billingValue;

  const SettlementDetail({
    this.idDetail,
    required this.idBus,
    required this.ritaseKe,
    required this.idPayment,
    required this.idNasabah,
    required this.idCustomerBilling,
    required this.total,
    required this.value,
    this.billingValue,
  });

  factory SettlementDetail.fromJson(Map<String, dynamic> json) {
    return SettlementDetail(
      idDetail: json['idDetail'],
      idBus: json['idBus'] ?? 0,
      ritaseKe: (json['ritaseKe'] ?? 0).toDouble(),
      idPayment: json['idPayment'] ?? 0,
      idNasabah: json['idNasabah'] ?? 0,
      idCustomerBilling: json['idCustomerBilling'] ?? 0,
      total: json['total'] ?? 0,
      value: json['value'] ?? 0,
      billingValue: json['billingValue'],
    );
  }

  Map<String, dynamic> toJson() => {
    "idDetail": idDetail ?? 0,
    "idBus": idBus,
    "ritaseKe": ritaseKe,
    "idPayment": idPayment,
    "idNasabah": idNasabah,
    "idCustomerBilling": idCustomerBilling,
    "total": total,
    "value": value
  };

  SettlementDetail copyWith({
    int? idDetail,
    int? idBus,
    double? ritaseKe,
    int? idPayment,
    int? idNasabah,
    int? idCustomerBilling,
    int? total,
    int? value,
    int? billingValue,
  }) {
    return SettlementDetail(
      idDetail: idDetail ?? this.idDetail,
      idBus: idBus ?? this.idBus,
      ritaseKe: ritaseKe ?? this.ritaseKe,
      idPayment: idPayment ?? this.idPayment,
      idNasabah: idNasabah ?? this.idNasabah,
      idCustomerBilling: idCustomerBilling ?? this.idCustomerBilling,
      total: total ?? this.total,
      value: value ?? this.value,
      billingValue: billingValue ?? this.billingValue,
    );
  }

  @override
  List<Object?> get props => [
    idDetail,
    idBus,
    ritaseKe,
    idPayment,
    idNasabah,
    idCustomerBilling,
    total,
    value,
    billingValue,
  ];
}