class KmUserAuditTrail {
  final int id;
  final String userName;

  const KmUserAuditTrail({
    required this.id,
    required this.userName,
  });

  factory KmUserAuditTrail.fromJson(Map<String, dynamic> json) {
    return KmUserAuditTrail(
      id: json['id'] as int,
      userName: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
  };
}