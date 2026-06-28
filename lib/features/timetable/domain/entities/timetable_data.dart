import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';

class TimetableData extends Equatable {
  final int? id;
  final ReferenceBus bus;
  final ReferenceDetail koridor;
  final String? tanggal;
  final double totalRitase;

  const TimetableData({
    this.id,
    required this.bus,
    required this.koridor,
    this.tanggal,
    required this.totalRitase,
  });

  factory TimetableData.fromJson(Map<String, dynamic> json) {
    return TimetableData(
      id: json['id'],
      bus: ReferenceBus.fromJson(json['bus'] ?? {}),
      koridor: ReferenceDetail.fromJson(json['koridor'] ?? {}),
      tanggal: json['tanggal'],
      totalRitase: (json['totalRitase'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "bus": bus.toJson(),
    "koridor": koridor.toJson(),
    "tanggal": tanggal,
    "totalRitase": totalRitase,
  };

  TimetableData copyWith({
    int? id,
    ReferenceBus? bus,
    ReferenceDetail? koridor,
    String? tanggal,
    double? totalRitase,
  }) {
    return TimetableData(
      id: id ?? this.id,
      bus: bus ?? this.bus,
      koridor: koridor ?? this.koridor,
      tanggal: tanggal ?? this.tanggal,
      totalRitase: totalRitase ?? this.totalRitase,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bus,
    koridor,
    tanggal,
    totalRitase,
  ];
}