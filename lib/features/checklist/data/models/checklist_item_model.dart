class ChecklistItemModel {
  final int id;
  final String code;
  final String tanggal;
  final String createdBy;
  final String createdDate;
  final String busNomorLambung;
  final String busPlatNomor;
  final String koridorName;
  final String pramugaraName;
  final String shiftName;
  final String statusCode;
  final String statusName;
  final String tipeFormCode;
  final String tipeFormName;

  ChecklistItemModel({
    required this.id,
    required this.code,
    required this.tanggal,
    required this.createdBy,
    required this.createdDate,
    required this.busNomorLambung,
    required this.busPlatNomor,
    required this.koridorName,
    required this.pramugaraName,
    required this.shiftName,
    required this.statusCode,
    required this.statusName,
    required this.tipeFormCode,
    required this.tipeFormName,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      tanggal: json['tanggal'] ?? '',
      createdBy: json['createdBy'] ?? '-',
      createdDate: json['createdDate'] ?? '',
      busNomorLambung: json['bus']?['nomorLambung'] ?? '-',
      busPlatNomor: json['bus']?['platNomor'] ?? '-',
      koridorName: json['koridor']?['name'] ?? '-',
      pramugaraName: json['pramugara']?['fullName'] ?? '-',
      shiftName: json['shift']?['name'] ?? '-',
      statusCode: json['status']?['code'] ?? '',
      statusName: json['status']?['name'] ?? '-',
      tipeFormCode: json['tipeForm']?['code'] ?? '',
      tipeFormName: json['tipeForm']?['name'] ?? '-',
    );
  }
}
