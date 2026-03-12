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