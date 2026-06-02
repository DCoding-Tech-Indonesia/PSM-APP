class AttendanceRequest {
  final int idUser;
  final double lokasiLat;
  final double lokasiLong;
  final int idShift;
  final int idBus;

  AttendanceRequest({
    required this.idUser,
    required this.lokasiLat,
    required this.lokasiLong,
    required this.idShift,
    required this.idBus,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'lokasiLat': lokasiLat,
      'lokasiLong': lokasiLong,
      'idShift': idShift,
      'idBus': idBus,
    };
  }
}
