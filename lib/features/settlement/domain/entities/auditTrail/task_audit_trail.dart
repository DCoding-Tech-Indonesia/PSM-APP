import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/module_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/status_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/user_audit_trail.dart';

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
}