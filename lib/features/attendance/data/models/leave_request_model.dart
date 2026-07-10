import 'package:travis/features/attendance/data/models/general_model.dart';

class LeaveRequestModel {
  final int id;
  final String alasan;
  final String? approvedAt;
  final String? approvedBy;
  final String createdAt;
  final String? rejectReason;
  final GeneralModel? shift;
  final String status;
  final String? tanggal;
  final String tanggalMulai;
  final String tanggalSelesai;
  final GeneralModel type;
  final LeaveRequestUserModel user;

  LeaveRequestModel({
    required this.id,
    required this.alasan,
    this.approvedAt,
    this.approvedBy,
    required this.createdAt,
    this.rejectReason,
    this.shift,
    required this.status,
    this.tanggal,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.type,
    required this.user,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] ?? 0,
      alasan: json['alasan'] ?? '',
      approvedAt: json['approvedAt'],
      approvedBy: json['approvedBy']?.toString(),
      createdAt: json['createdAt'] ?? '',
      rejectReason: json['rejectReason'],
      shift: json['shift'] != null
          ? GeneralModel.fromJson(json['shift'])
          : null,
      status: json['status'] ?? '',
      tanggal: json['tanggal'],
      tanggalMulai: json['tanggalMulai'] ?? '',
      tanggalSelesai: json['tanggalSelesai'] ?? '',
      type: json['type'] != null
          ? GeneralModel.fromJson(json['type'])
          : GeneralModel(id: 0, code: '', name: ''),
      user: json['user'] != null
          ? LeaveRequestUserModel.fromJson(json['user'])
          : LeaveRequestUserModel(id: 0, userName: '', fullName: ''),
    );
  }
}

class LeaveRequestUserModel {
  final int id;
  final String userName;
  final String fullName;

  LeaveRequestUserModel({
    required this.id,
    required this.userName,
    required this.fullName,
  });

  factory LeaveRequestUserModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestUserModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}
