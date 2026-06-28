class SettlementUserAuditTrail {
  final int id;
  final String userName;

  SettlementUserAuditTrail({
    required this.id,
    required this.userName,
  });

  factory SettlementUserAuditTrail.fromJson(Map<String, dynamic> json) {
    return SettlementUserAuditTrail(
      id: json['id'],
      userName: json['userName'],
    );
  }
}