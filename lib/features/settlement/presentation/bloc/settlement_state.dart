import 'dart:io';
import 'package:equatable/equatable.dart';

class SettlementState extends Equatable {
  final File? debitKreditPict;
  final File? brizziPict;
  final File? qrisPict;

  final Map<String, Map<String, int>> paymentData;

  const SettlementState({
    this.debitKreditPict,
    this.brizziPict,
    this.qrisPict,
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
    File? debitKreditPict,
    File? brizziPict,
    File? qrisPict,
    Map<String, Map<String, int>>? paymentData,
  }) {
    return SettlementState(
      debitKreditPict: debitKreditPict ?? this.debitKreditPict,
      brizziPict: brizziPict ?? this.brizziPict,
      qrisPict: qrisPict ?? this.qrisPict,
      paymentData: paymentData ?? this.paymentData,
    );
  }

  @override
  List<Object?> get props => [
    debitKreditPict,
    brizziPict,
    qrisPict,
    paymentData,
  ];
}