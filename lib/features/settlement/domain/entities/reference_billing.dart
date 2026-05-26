class ReferenceBilling {
  final int id;
  final String code;
  final String value;

  ReferenceBilling({
    required this.id,
    required this.code,
    required this.value,
  });

  factory ReferenceBilling.fromJson(Map<String, dynamic> json) {
    return ReferenceBilling(
      id: json['id'],
      code: json['code'],
      value: json['value'],
    );
  }
}