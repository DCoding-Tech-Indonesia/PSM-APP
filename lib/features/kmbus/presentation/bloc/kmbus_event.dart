import 'dart:io';

abstract class KmbusEvent {}

class PageDashboardLoad extends KmbusEvent {}

class KmbusTitikAwalInputLoad extends KmbusEvent {
  final int idShift;
  final int idKoridorShift;
  final int idBusShift;

  KmbusTitikAwalInputLoad(this.idShift, this.idKoridorShift, this.idBusShift);
}

class KmbusTitikAkhirInputLoad extends KmbusEvent {
  final int idAuditTrail;

  KmbusTitikAkhirInputLoad(this.idAuditTrail);
}

class UploadOcrAwalEvent extends KmbusEvent {
  final File file;

  UploadOcrAwalEvent(this.file);
}

class UploadOcrAkhirEvent extends KmbusEvent {
  final File file;

  UploadOcrAkhirEvent(this.file);
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

class EditOdometerAwal extends KmbusEvent {
  final int odometerVal;

  EditOdometerAwal(this.odometerVal);
}

class EditOdometerAkhir extends KmbusEvent {
  final int odometerVal;

  EditOdometerAkhir(this.odometerVal);
}

class RemoveDocumentById extends KmbusEvent {
  final int idDocument;

  RemoveDocumentById(this.idDocument);
}

class SubmitTitikAwal extends KmbusEvent {}

class SubmitTitikAkhir extends KmbusEvent {}

class SubmitWorkflow extends KmbusEvent {
  final String reason;
  final int idAuditTrail;

  SubmitWorkflow(this.reason, this.idAuditTrail);
}
