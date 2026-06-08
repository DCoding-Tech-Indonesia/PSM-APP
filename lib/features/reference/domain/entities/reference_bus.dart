class ReferenceBus {
  final int id;
  final String nomorLambung;
  final String platNomor;

  ReferenceBus({
    required this.id,
    required this.nomorLambung,
    required this.platNomor,
  });

  factory ReferenceBus.fromJson(Map<String, dynamic> json) {
    return ReferenceBus(
      id: json['id'],
      nomorLambung: json['code'],
      platNomor: json['name'],
    );
  }
}