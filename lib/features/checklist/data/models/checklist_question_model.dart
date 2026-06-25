import 'package:equatable/equatable.dart';

class ChecklistQuestionModel extends Equatable {
  final int id;
  final String? grup;
  final String? sanksi;
  final String status;
  final String tipeForm;
  final String uraian;

  // Nilai inputan pengguna (Ya/Tidak atau boolean dll)
  final bool? value; 
  final String? notes;

  const ChecklistQuestionModel({
    required this.id,
    this.grup,
    this.sanksi,
    required this.status,
    required this.tipeForm,
    required this.uraian,
    this.value,
    this.notes,
  });

  factory ChecklistQuestionModel.fromJson(Map<String, dynamic> json) {
    return ChecklistQuestionModel(
      id: json['id'],
      grup: json['grup'],
      sanksi: json['sanksi'],
      status: json['status'] ?? '',
      tipeForm: json['tipeForm'] ?? '',
      uraian: json['uraian'] ?? '',
    );
  }

  ChecklistQuestionModel copyWith({
    int? id,
    String? grup,
    String? sanksi,
    String? status,
    String? tipeForm,
    String? uraian,
    bool? value,
    String? notes,
  }) {
    return ChecklistQuestionModel(
      id: id ?? this.id,
      grup: grup ?? this.grup,
      sanksi: sanksi ?? this.sanksi,
      status: status ?? this.status,
      tipeForm: tipeForm ?? this.tipeForm,
      uraian: uraian ?? this.uraian,
      value: value ?? this.value,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        grup,
        sanksi,
        status,
        tipeForm,
        uraian,
        value,
        notes,
      ];
}
