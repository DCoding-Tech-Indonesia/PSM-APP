class ReferenceDetail {
  final int id;
  final String code;
  final String name;

  ReferenceDetail({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ReferenceDetail.fromJson(Map<String, dynamic> json) {
    return ReferenceDetail(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? json['namaLokasi'] ?? '',
    );
  }
}