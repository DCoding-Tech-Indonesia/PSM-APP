import 'package:travis/features/attendance/data/models/general_model.dart';
import 'package:travis/features/reference/domain/entities/reference_bus.dart';

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
    // Handle two response shapes:
    // 1. /jadwal/list → has 'koridor' as object {id, name}, no 'lokasi'
    // 2. Other endpoints → has 'lokasi' as object {id, code, koridor, namaLokasi}
    final lokasiJson = json['lokasi'] as Map<String, dynamic>?;
    final koridorJson = json['koridor'] as Map<String, dynamic>?;

    ScheduleLocation lokasi;
    if (lokasiJson != null) {
      lokasi = ScheduleLocation.fromJson(lokasiJson);
    } else if (koridorJson != null) {
      lokasi = ScheduleLocation(
        id: koridorJson['id'] ?? 0,
        code: koridorJson['code'] ?? '',
        koridor: koridorJson['id'] ?? 0,
        namaLokasi: koridorJson['name'] ?? '',
      );
    } else {
      lokasi = ScheduleLocation(id: 0, code: '', koridor: 0, namaLokasi: '');
    }

    return CoreScheduleModel(
      id: json['id'] ?? 0,
      bus: ReferenceBus.fromJson(json['bus'] ?? {}),
      isCadangan: json['isCadangan'] ?? false,
      lokasi: lokasi,
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
    // 'koridor' bisa berupa int langsung atau object {id, name}
    final koridorRaw = json['koridor'];
    final int koridorId = koridorRaw is int
        ? koridorRaw
        : (koridorRaw is Map ? (koridorRaw['id'] ?? 0) : 0);

    return ScheduleLocation(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      koridor: koridorId,
      namaLokasi: json['namaLokasi'] ?? '',
    );
  }
}
