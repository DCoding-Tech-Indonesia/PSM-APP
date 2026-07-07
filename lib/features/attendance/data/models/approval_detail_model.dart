import 'package:psm_mobile/features/attendance/data/models/general_model.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

class ApprovalDetailModel {
  final int id;
  final String status;
  final String alasan;
  final String tanggal;
  final String? rejectReason;
  final String? approvedAt;
  final ScheduleModel jadwal;
  final ScheduleLocation lokasi;
  final GeneralModel shift;
  final UserApprovalModel replacement;
  final UserApprovalModel requester;

  ApprovalDetailModel({
    required this.id,
    required this.status,
    required this.alasan,
    required this.tanggal,
    this.rejectReason,
    this.approvedAt,
    required this.jadwal,
    required this.lokasi,
    required this.shift,
    required this.replacement,
    required this.requester,
  });

  factory ApprovalDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse nested jadwal structure from API response
    final jadwalJson = json['jadwal'] ?? {};
    final jadwal = ScheduleModel(
      id: jadwalJson['id'] ?? 0,
      isCadangan: jadwalJson['isCadangan'] ?? false,
      lokasi: jadwalJson['lokasi'] != null
          ? ScheduleLocation.fromJson(jadwalJson['lokasi'])
          : ScheduleLocation(id: 0, name: '', code: ''),
      shift: jadwalJson['shift'] != null
          ? GeneralModel.fromJson(jadwalJson['shift'])
          : GeneralModel(id: 0, name: '', code: ''),
      tanggal: jadwalJson['tanggal'] ?? '',
    );

    return ApprovalDetailModel(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'PENDING_REPL',
      alasan: json['alasan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      rejectReason: json['rejectReason'],
      approvedAt: json['approvedAt'],
      jadwal: jadwal,
      lokasi: ScheduleLocation.fromJson(json['lokasi'] ?? {}),
      shift: GeneralModel.fromJson(json['shift'] ?? {}),
      replacement: UserApprovalModel.fromJson(json['replacement'] ?? {}),
      requester: UserApprovalModel.fromJson(json['requester'] ?? {}),
    );
  }
}

class UserApprovalModel {
  final int id;
  final String userName;
  final String name;

  UserApprovalModel({
    required this.id,
    required this.userName,
    required this.name,
  });

  factory UserApprovalModel.fromJson(Map<String, dynamic> json) {
    return UserApprovalModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
    );
  }
}
