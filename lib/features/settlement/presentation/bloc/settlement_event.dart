import 'dart:io';

abstract class SettlementEvent {}

class SettlementPictChanged extends SettlementEvent {
  final File? value;
  SettlementPictChanged(this.value);
}

class PaymentCountChanged extends SettlementEvent {
  final String method;
  final String category;
  final int value;

  PaymentCountChanged({
    required this.method,
    required this.category,
    required this.value,
  });
}