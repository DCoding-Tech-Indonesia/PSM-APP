import 'package:equatable/equatable.dart';

class ReferenceDetail extends Equatable {
  final int id;
  final String code;
  final String name;

  const ReferenceDetail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ReferenceDetail.fromJson(Map<String, dynamic> json) {
    return ReferenceDetail(
      id: json['id'],
      code: json['code'] ?? json['email'] ?? json['nip'] ?? '',
      name: json['name'] ?? json['namaLokasi'] ?? json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "code": code, "name": name};

  ReferenceDetail copyWith({int? id, String? code, String? name}) {
    return ReferenceDetail(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, code, name];
}
