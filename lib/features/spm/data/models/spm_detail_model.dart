import 'package:psm_mobile/features/attendance/data/models/general_model.dart';

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

  User({required this.id, required this.userName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], userName: json['userName']);
  }
}

class DataAfter {
  final int? idKoridor;
  final int? idTypePemeriksaan;
  final int? idBus;
  final int? idHalte;
  final List<Detail> detail;

  DataAfter({
    this.idKoridor,
    this.idTypePemeriksaan,
    this.idBus,
    this.idHalte,
    required this.detail,
  });

  factory DataAfter.fromJson(Map<String, dynamic> json) {
    return DataAfter(
      idKoridor: (json['idKoridor'] as num?)?.toInt(),
      idTypePemeriksaan: (json['idTypePemeriksaan'] as num?)?.toInt(),
      idBus: (json['idBus'] as num?)?.toInt(),
      idHalte: (json['idHalte'] as num?)?.toInt(),
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
  final int nilaiCapaian;
  final double bobotCapaian;
  final int nilaiStandar;

  Detail({
    required this.idIndikatorSpm,
    required this.nilaiCapaian,
    required this.bobotCapaian,
    required this.nilaiStandar,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      idIndikatorSpm:
          (json['idIndikatorSPM'] ?? json['idIndikatorSpm'] as num?)?.toInt() ??
          0,
      nilaiCapaian: (json['nilaiCapaian'] as num?)?.toInt() ?? 0,
      bobotCapaian: (json['bobotCapaian'] as num?)?.toDouble() ?? 0.0,
      nilaiStandar: (json['nilaiStandar'] as num?)?.toInt() ?? 0,
    );
  }
}
