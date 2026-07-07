import 'package:psm_mobile/features/attendance/data/models/general_model.dart';

class ScheduleModel {
  final int id;
  final bool isCadangan;
  final ScheduleLocation lokasi;
  final GeneralModel shift;
  final String tanggal;

  ScheduleModel({
    required this.id,
    required this.isCadangan,
    required this.lokasi,
    required this.shift,
    required this.tanggal,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      isCadangan: json['isCadangan'] ?? false,
      lokasi: ScheduleLocation.fromJson(json['lokasi'] ?? {}),
      shift: GeneralModel.fromJson(json['shift'] ?? {}),
      tanggal: json['tanggal'] ?? '',
    );
  }
}

class ScheduleLocation {
  final int id;
  final String code;
  final String name;

  ScheduleLocation({required this.id, required this.code, required this.name});

  factory ScheduleLocation.fromJson(Map<String, dynamic> json) {
    return ScheduleLocation(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? json['namaLokasi'] ?? '',
    );
  }
}
