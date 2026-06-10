class GeneralModel {
  final int id;
  final String code;
  final String name;

  GeneralModel({required this.id, required this.code, required this.name});

  factory GeneralModel.fromJson(Map<String, dynamic> json) {
    return GeneralModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
