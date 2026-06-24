import 'package:psm_mobile/features/attendance/data/models/general_model.dart';

class SpmQuestionModel {
  final int id;
  final double bobotCapaian;
  final GeneralModel categorySPM;
  final String code;
  final String indikator;
  final GeneralModel jenisObjectSPM;
  final String name;
  final String nilai;
  final double targetCapaian;
  final String uraian;
  double? nilaiInput;

  SpmQuestionModel({
    required this.id,
    required this.bobotCapaian,
    required this.categorySPM,
    required this.code,
    required this.indikator,
    required this.jenisObjectSPM,
    required this.name,
    required this.nilai,
    required this.targetCapaian,
    required this.uraian,
    this.nilaiInput,
  });

  factory SpmQuestionModel.fromJson(Map<String, dynamic> json) {
    return SpmQuestionModel(
      id: json['id'] ?? 0,
      bobotCapaian: json['bobotCapaian'] ?? 0,
      categorySPM: GeneralModel.fromJson(json['categorySPM'] ?? {}),
      code: json['code'] ?? '',
      indikator: json['indikator'] ?? '',
      jenisObjectSPM: GeneralModel.fromJson(json['jenisObjectSPM'] ?? {}),
      name: json['name'] ?? '',
      nilai: json['nilai'] ?? '',
      targetCapaian: json['targetCapaian'] ?? 0,
      uraian: json['uraian'] ?? '',
      nilaiInput: double.tryParse(json['nilai'] ?? '0'),
    );
  }
}
