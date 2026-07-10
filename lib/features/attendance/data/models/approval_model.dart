import 'package:travis/features/attendance/data/models/approval_detail_model.dart';
import 'package:travis/features/attendance/data/models/general_model.dart';
import 'package:travis/features/attendance/data/models/schedule_model.dart';

class ApprovalModel {
  final int id;
  final String alasan;
  final String approvedAt;
  final UserApprovalModel? approvedBy;
  final String createdAt;
  final ScheduleLocation lokasi;
  final String rejectReason;
  final UserApprovalModel replacement;
  final UserApprovalModel requester;
  final GeneralModel shift;
  final String status;
  final String tanggal;

  ApprovalModel({
    required this.id,
    required this.alasan,
    required this.approvedAt,
    required this.approvedBy,
    required this.createdAt,
    required this.lokasi,
    required this.rejectReason,
    required this.replacement,
    required this.requester,
    required this.shift,
    required this.status,
    required this.tanggal,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'] ?? 0,
      alasan: json['alasan'] ?? '',
      approvedAt: json['approvedAt'] ?? '',
      approvedBy: json['approvedBy'] != null
          ? UserApprovalModel.fromJson(json['approvedBy'])
          : null,
      createdAt: json['createdAt'] ?? '',
      lokasi: ScheduleLocation.fromJson(json['lokasi'] ?? {}),
      rejectReason: json['rejectReason'] ?? '',
      replacement: UserApprovalModel.fromJson(json['replacement'] ?? {}),
      requester: UserApprovalModel.fromJson(json['requester'] ?? {}),
      shift: GeneralModel.fromJson(json['shift'] ?? {}),
      status: json['status'] ?? '',
      tanggal: json['tanggal'] ?? '',
    );
  }
}
