class KmStatusAuditTrail {
  final int id;
  final String code;
  final String name;

  const KmStatusAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory KmStatusAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmStatusAuditTrail(
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
