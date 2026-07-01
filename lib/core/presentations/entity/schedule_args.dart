class ScheduleArgs {
  final int idShift;
  final int idKoridorShift;
  final int idBusShift;
  final int? idAuditTrail;
  final double? long;
  final double? lat;

  ScheduleArgs({
    required this.idShift,
    required this.idKoridorShift,
    required this.idBusShift,
    this.idAuditTrail,
    required this.long,
    required this.lat,
  });
}
