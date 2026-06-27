import 'package:psm_mobile/features/attendance/data/models/general_model.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';

class SpmDetailModel {
  final int id;
  final GeneralModel module;
  final dynamic dataBefore;
  final DataAfter dataAfter;
  final User createdBy;
  final User? approvedBy;
  final User? updatedBy;
  final DateTime createdDate;
  final DateTime? approvedDate;
  final DateTime? updatedDate;
  final String? rejectNote;
  final String? reason;
  final String actionType;

  SpmDetailModel({
    required this.id,
    required this.module,
    required this.dataBefore,
    required this.dataAfter,
    required this.createdBy,
    required this.approvedBy,
    required this.updatedBy,
    required this.createdDate,
    required this.approvedDate,
    required this.updatedDate,
    required this.rejectNote,
    required this.reason,
    required this.actionType,
  });

  factory SpmDetailModel.fromJson(Map<String, dynamic> json) {
    return SpmDetailModel(
      id: json['id'],
      module: GeneralModel.fromJson(json['module']),
      dataBefore: json['dataBefore'],
      dataAfter: DataAfter.fromJson(json['dataAfter']),
      createdBy: User.fromJson(json['createdBy']),
      approvedBy: json['approvedBy'] != null
          ? User.fromJson(json['approvedBy'])
          : null,
      updatedBy: json['updatedBy'] != null
          ? User.fromJson(json['updatedBy'])
          : null,
      createdDate: DateTime.parse(json['createdDate']),
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
      rejectNote: json['rejectNote'],
      reason: json['reason'],
      actionType: json['actionType'],
    );
  }
}

class User {
  final int id;
  final String userName;
  final String fullName;

  User({required this.id, required this.userName, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      userName: json['userName'],
      fullName: json['fullName'],
    );
  }
}

class DataAfter {
  final int? idKoridor;
  final GeneralModel? koridor;
  final int? idTypePemeriksaan;
  final GeneralModel? jenisObjectSPM;
  final int? idBus;
  final ReferenceBus? bus;
  final int? idHalte;
  final GeneralModel? halte;
  final List<Detail> detail;

  DataAfter({
    this.idKoridor,
    this.koridor,
    this.idTypePemeriksaan,
    this.jenisObjectSPM,
    this.idBus,
    this.bus,
    this.idHalte,
    this.halte,
    required this.detail,
  });

  factory DataAfter.fromJson(Map<String, dynamic> json) {
    return DataAfter(
      idKoridor: (json['idKoridor'] as num?)?.toInt(),
      koridor: json['koridor'] != null
          ? GeneralModel.fromJson(json['koridor'])
          : null,
      idTypePemeriksaan: (json['idTypePemeriksaan'] as num?)?.toInt(),
      jenisObjectSPM: json['jenisObjectSPM'] != null
          ? GeneralModel.fromJson(json['jenisObjectSPM'])
          : null,
      idBus: (json['idBus'] as num?)?.toInt(),
      bus: json['bus'] != null ? ReferenceBus.fromJson(json['bus']) : null,
      idHalte: (json['idHalte'] as num?)?.toInt(),
      halte: json['halte'] != null
          ? GeneralModel.fromJson(json['halte'])
          : null,
      detail: json['detail'] != null
          ? (json['detail'] as List)
                .map((e) => Detail.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}

class Detail {
  final int idIndikatorSpm;
  final SpmQuestionModel? indikatorSpm;
  final GeneralModel? categorySpm;
  final int nilaiCapaian;
  final double bobotCapaian;
  final int nilaiStandar;

  Detail({
    required this.idIndikatorSpm,
    this.indikatorSpm,
    this.categorySpm,
    required this.nilaiCapaian,
    required this.bobotCapaian,
    required this.nilaiStandar,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      idIndikatorSpm:
          (json['idIndikatorSPM'] ?? json['idIndikatorSpm'] as num?)?.toInt() ??
          0,
      indikatorSpm: json['indikatorSPM'] != null
          ? SpmQuestionModel.fromJson(json['indikatorSPM'])
          : null,
      categorySpm: json['categorySPM'] != null
          ? GeneralModel.fromJson(json['categorySPM'])
          : null,
      nilaiCapaian: (json['nilaiCapaian'] as num?)?.toInt() ?? 0,
      bobotCapaian: (json['bobotCapaian'] as num?)?.toDouble() ?? 0.0,
      nilaiStandar: (json['nilaiStandar'] as num?)?.toInt() ?? 0,
    );
  }
}
