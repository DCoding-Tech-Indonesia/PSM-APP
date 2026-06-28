class ScheduleArgs {
  final int idShift;
  final int idKoridorShift;
  final int idBusShift;
  final int? idAuditTrail;

  ScheduleArgs({
    required this.idShift,
    required this.idKoridorShift,
    required this.idBusShift,
    this.idAuditTrail,
  });
}
