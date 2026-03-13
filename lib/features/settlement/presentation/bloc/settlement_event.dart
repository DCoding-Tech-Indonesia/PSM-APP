import 'dart:io';

abstract class SettlementEvent {}

class DebitKreditPictChanged extends SettlementEvent {
  final File? value;
  DebitKreditPictChanged(this.value);
}

class BrizziPictChanged extends SettlementEvent {
  final File? value;
  BrizziPictChanged(this.value);
}

class QrisPictChanged extends SettlementEvent {
  final File? value;
  QrisPictChanged(this.value);
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