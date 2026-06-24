class SpmTaskModel {
  final int id;
  final String statusCode;
  final String statusName;
  final String createdBy;
  final String createdDate;
  final String moduleName;

  SpmTaskModel({
    required this.id,
    required this.statusCode,
    required this.statusName,
    required this.createdBy,
    required this.createdDate,
    required this.moduleName,
  });

  factory SpmTaskModel.fromJson(Map<String, dynamic> json) {
    return SpmTaskModel(
      id: json['id'] ?? 0,
      statusCode: json['status']?['code'] ?? '',
      statusName: json['status']?['name'] ?? '-',
      createdBy: json['createdBy']?['userName'] ?? '-',
      createdDate: json['createdDate'] ?? '',
      moduleName: json['module']?['name'] ?? 'SPM',
    );
  }
}
