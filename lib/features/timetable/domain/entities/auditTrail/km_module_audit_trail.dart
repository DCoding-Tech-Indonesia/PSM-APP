class KmModuleAuditTrail {
  final int id;
  final String code;
  final String name;

  const KmModuleAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory KmModuleAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmModuleAuditTrail(
      id: json['id'] as int,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}
