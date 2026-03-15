import 'dart:io';
import 'package:equatable/equatable.dart';

class SettlementState extends Equatable {
  final File? settlementPict;
  final Map<String, Map<String, int>> paymentData, pricing;

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
    this.pricing = const {
      "card": {
        "pelajar": 2500,
        "umum": 3000,
        "lansia": 2000,
      },
      "brizzi": {
        "pelajar": 2500,
        "umum": 3000,
        "lansia": 2000,
      },
      "qris": {
        "pelajar": 2500,
        "umum": 3000,
        "lansia": 2000,
      },
    },
  });

  SettlementState copyWith({
    File? settlementPict,
    Map<String, Map<String, int>>? paymentData,
    Map<String, Map<String, int>>? pricing,
  }) {
    return SettlementState(
      settlementPict: settlementPict ?? this.settlementPict,
      paymentData: paymentData ?? this.paymentData,
      pricing: pricing ?? this.pricing,
    );
  }

  @override
  List<Object?> get props => [
    settlementPict,
    paymentData,
    pricing,
  ];
}