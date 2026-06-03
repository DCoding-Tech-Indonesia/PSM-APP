import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/status_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/user_audit_trail.dart';
import 'module_audit_trail.dart';

class TaskAuditTrail {
  final int id;
  final UserAuditTrail createdBy;
  final String createdDate;
  final ModuleAuditTrail module;
  final StatusAuditTrail status;
  final UserAuditTrail? approvedBy;
  final String? approvedDate;
  final UserAuditTrail? updatedBy;
  final String? updatedDate;

  TaskAuditTrail({
    required this.id,
    required this.createdBy,
    required this.createdDate,
    required this.module,
    required this.status,
    this.approvedBy,
    this.approvedDate,
    this.updatedBy,
    this.updatedDate,
  });

  factory TaskAuditTrail.fromJson(Map<String, dynamic> json) {
    return TaskAuditTrail(
      id: json['id'],
      createdDate: json['createdDate'],

      createdBy: UserAuditTrail.fromJson(json['createdBy']),
      module: ModuleAuditTrail.fromJson(json['module']),
      status: StatusAuditTrail.fromJson(json['status']),

      approvedDate: json['approvedDate'],
      approvedBy: json['approvedBy'] != null
          ? UserAuditTrail.fromJson(json['approvedBy'])
          : null,

      updatedDate: json['updatedDate'],
      updatedBy: json['updatedBy'] != null
          ? UserAuditTrail.fromJson(json['updatedBy'])
          : null,
    );
  }
}