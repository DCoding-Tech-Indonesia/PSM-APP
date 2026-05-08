class AttendanceRequest {
  final int idUser;
  final double lokasiLat;
  final double lokasiLong;

  AttendanceRequest({
    required this.idUser,
    required this.lokasiLat,
    required this.lokasiLong,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'lokasiLat': lokasiLat,
      'lokasiLong': lokasiLong,
    };
  }
}
