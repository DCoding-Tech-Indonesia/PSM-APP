class ModuleAuditTrail {
  final int id;
  final String code;
  final String name;

  ModuleAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ModuleAuditTrail.fromJson(Map<String, dynamic> json) {
    return ModuleAuditTrail(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}