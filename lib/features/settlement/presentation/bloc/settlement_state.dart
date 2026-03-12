import 'dart:io';
import 'package:equatable/equatable.dart';

class SettlementState extends Equatable {
  final File? debitKreditPict;
  final File? brizziPict;
  final File? qrisPict;

  const SettlementState({
    this.debitKreditPict,
    this.brizziPict,
    this.qrisPict,
  });

  SettlementState copyWith({
    File? debitKreditPict,
    File? brizziPict,
    File? qrisPict,
  }) {
    return SettlementState(
      debitKreditPict: debitKreditPict ?? this.debitKreditPict,
      brizziPict: brizziPict ?? this.brizziPict,
      qrisPict: qrisPict ?? this.qrisPict,
    );
  }

  @override
  List<Object?> get props => [debitKreditPict, brizziPict, qrisPict];
}