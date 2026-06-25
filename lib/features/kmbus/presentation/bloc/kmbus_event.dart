import 'dart:io';

abstract class KmbusEvent {}

class PageDashboardLoad extends KmbusEvent {}

class KmbusTitikAwalInputLoad extends KmbusEvent {
  KmbusTitikAwalInputLoad();
}

class UploadOcrEvent extends KmbusEvent {
  final File file;

  UploadOcrEvent(this.file);
}

class SelectKoridor extends KmbusEvent {
  final int id;
  final String namaKoridor;

  SelectKoridor(this.id, this.namaKoridor);
}

class SelectBus extends KmbusEvent {
  final int id;
  final String noUnit;

  SelectBus(this.id, this.noUnit);
}

class EditOdometer extends KmbusEvent {
  final int odometerVal;

  EditOdometer(this.odometerVal);
}