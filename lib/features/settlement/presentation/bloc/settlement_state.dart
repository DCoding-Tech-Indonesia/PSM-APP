import 'dart:io';
import 'package:equatable/equatable.dart';

class SettlementState extends Equatable {
  final File? settlementPict;
  final Map<String, Map<String, int>> paymentData;

  const SettlementState({
    this.settlementPict,
    this.paymentData = const {
      "card": {
        "pelajar": 0,
        "umum": 0,
        "lansia": 0,
      },
      "brizzi": {
        "pelajar": 0,
        "umum": 0,
        "lansia": 0,
      },
      "qris": {
        "pelajar": 0,
        "umum": 0,
        "lansia": 0,
      },
    },
  });

  SettlementState copyWith({
    File? settlementPict,
    Map<String, Map<String, int>>? paymentData,
  }) {
    return SettlementState(
      settlementPict: settlementPict ?? this.settlementPict,
      paymentData: paymentData ?? this.paymentData,
    );
  }

  @override
  List<Object?> get props => [
    settlementPict,
    paymentData,
  ];
}