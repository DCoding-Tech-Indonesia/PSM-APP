import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_status_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_user_audit_trail.dart';
import 'settlement_module_audit_trail.dart';

class SettlementTaskAuditTrail {
  final int id;
  final SettlementUserAuditTrail createdBy;
  final String createdDate;
  final SettlementModuleAuditTrail module;
  final SettlementStatusAuditTrail status;
  final SettlementUserAuditTrail? approvedBy;
  final String? approvedDate;
  final SettlementUserAuditTrail? updatedBy;
  final String? updatedDate;

  final String? namaKoridor;
  final String? noPolisi;
  final double? ritase;
  final int? totalPenumpangKeseluruhan;
  final int? totalPendapatanPertitase;

  SettlementTaskAuditTrail({
    required this.id,
    required this.createdBy,
    required this.createdDate,
    required this.module,
    required this.status,
    this.approvedBy,
    this.approvedDate,
    this.updatedBy,
    this.updatedDate,

    this.namaKoridor,
    this.noPolisi,
    this.ritase,
    this.totalPenumpangKeseluruhan,
    this.totalPendapatanPertitase,
  });

  factory SettlementTaskAuditTrail.fromJson(Map<String, dynamic> json) {
    return SettlementTaskAuditTrail(
      id: json['id'],
      createdDate: json['createdDate'],

      createdBy: SettlementUserAuditTrail.fromJson(json['createdBy']),
      module: SettlementModuleAuditTrail.fromJson(json['module']),
      status: SettlementStatusAuditTrail.fromJson(json['status']),

      approvedDate: json['approvedDate'],
      approvedBy: json['approvedBy'] != null
          ? SettlementUserAuditTrail.fromJson(json['approvedBy'])
          : null,

      updatedDate: json['updatedDate'],
      updatedBy: json['updatedBy'] != null
          ? SettlementUserAuditTrail.fromJson(json['updatedBy'])
          : null,

      namaKoridor: json['namaKoridor'],
      noPolisi: json['noPolisi'],
      ritase: json['ritase'],
      totalPenumpangKeseluruhan: json['totalPenumpangKeseluruhan'],
      totalPendapatanPertitase: json['totalPendapatanPertitase'],
    );
  }
}