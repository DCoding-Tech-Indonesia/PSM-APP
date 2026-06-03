class UserAuditTrail {
  final int id;
  final String userName;

  UserAuditTrail({
    required this.id,
    required this.userName,
  });

  factory UserAuditTrail.fromJson(Map<String, dynamic> json) {
    return UserAuditTrail(
      id: json['id'],
      userName: json['userName'],
    );
  }
}