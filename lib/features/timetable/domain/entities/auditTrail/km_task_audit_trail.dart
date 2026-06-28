import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_data_after_audit_trail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_module_audit_trail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_status_audit_trail.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_user_audit_trail.dart';

class KmTaskAuditTrail {
  final int id;
  final KmModuleAuditTrail module;
  final KmUserAuditTrail createdBy;
  final DateTime createdDate;
  final KmUserAuditTrail? approvedBy;
  final DateTime? approvedDate;
  final KmUserAuditTrail? updatedBy;
  final DateTime? updatedDate;
  final KmStatusAuditTrail status;
  final String namaKoridor;
  final String noPolisi;
  final String? namaPramugara;
  final KmDataAfterAuditTrail dataAfter;

  const KmTaskAuditTrail({
    required this.id,
    required this.module,
    required this.createdBy,
    required this.createdDate,
    this.approvedBy,
    this.approvedDate,
    this.updatedBy,
    this.updatedDate,
    required this.status,
    required this.namaKoridor,
    required this.noPolisi,
    this.namaPramugara,
    required this.dataAfter,
  });

  factory KmTaskAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmTaskAuditTrail(
      id: json['id'] as int,
      module: KmModuleAuditTrail.fromJson(json['module']),
      createdBy: KmUserAuditTrail.fromJson(json['createdBy']),
      createdDate: DateTime.parse(json['createdDate']),
      approvedBy: json['approvedBy'] != null
          ? KmUserAuditTrail.fromJson(json['approvedBy'])
          : null,
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      updatedBy: json['updatedBy'] != null
          ? KmUserAuditTrail.fromJson(json['updatedBy'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
      status: KmStatusAuditTrail.fromJson(json['status']),
      namaKoridor: json['namaKoridor'] ?? '',
      noPolisi: json['noPolisi'] ?? '',
      namaPramugara: json['namaPramugara'],
      dataAfter: KmDataAfterAuditTrail.fromJson(json['dataAfter']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module.toJson(),
      'createdBy': createdBy.toJson(),
      'createdDate': createdDate.toIso8601String(),
      'approvedBy': approvedBy?.toJson(),
      'approvedDate': approvedDate?.toIso8601String(),
      'updatedBy': updatedBy?.toJson(),
      'updatedDate': updatedDate?.toIso8601String(),
      'status': status.toJson(),
      'namaKoridor': namaKoridor,
      'noPolisi': noPolisi,
      'namaPramugara': namaPramugara,
      'dataAfter': dataAfter,
    };
  }
}