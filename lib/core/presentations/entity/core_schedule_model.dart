import 'package:psm_mobile/features/attendance/data/models/general_model.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_bus.dart';

class CoreScheduleModel {
  final int id;
  final ReferenceBus bus;
  final bool isCadangan;
  final ScheduleLocation lokasi;
  final GeneralModel shift;
  final String tanggal;

  CoreScheduleModel({
    required this.id,
    required this.bus,
    required this.isCadangan,
    required this.lokasi,
    required this.shift,
    required this.tanggal,
  });

  factory CoreScheduleModel.fromJson(Map<String, dynamic> json) {
    return CoreScheduleModel(
      id: json['id'] ?? 0,
      bus: ReferenceBus.fromJson(json['bus'] ?? {}),
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
  final int koridor;
  final String namaLokasi;

  ScheduleLocation({
    required this.id,
    required this.code,
    required this.koridor,
    required this.namaLokasi,
  });

  factory ScheduleLocation.fromJson(Map<String, dynamic> json) {
    return ScheduleLocation(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      koridor: json['koridor'] ?? '',
      namaLokasi: json['namaLokasi'] ?? '',
    );
  }
}
