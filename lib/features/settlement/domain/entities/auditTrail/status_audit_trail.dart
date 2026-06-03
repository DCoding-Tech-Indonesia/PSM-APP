class StatusAuditTrail {
  final int id;
  final String code;
  final String name;

  StatusAuditTrail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory StatusAuditTrail.fromJson(Map<String, dynamic> json) {
    return StatusAuditTrail(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }
}