class SettlementStatusAuditTrail {
  final int id;
  final String code;
  final String name;

  SettlementStatusAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory SettlementStatusAuditTrail.fromJson(Map<String, dynamic> json) {
    return SettlementStatusAuditTrail(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}