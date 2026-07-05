class CreateSettlementData {
  final int auditTrailId;

  const CreateSettlementData({required this.auditTrailId});

  factory CreateSettlementData.fromJson(Map<String, dynamic> json) {
    return CreateSettlementData(
      auditTrailId: json['auditTrailId'] ?? 0,
    );
  }
}