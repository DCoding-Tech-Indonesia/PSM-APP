class SettlementModuleAuditTrail {
  final int id;
  final String code;
  final String name;

  SettlementModuleAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory SettlementModuleAuditTrail.fromJson(Map<String, dynamic> json) {
    return SettlementModuleAuditTrail(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}