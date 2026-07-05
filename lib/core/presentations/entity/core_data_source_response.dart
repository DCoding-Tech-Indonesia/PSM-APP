class CoreDataSourceResponse {
  final String message;
  final List<bool> data;

  const CoreDataSourceResponse({
    required this.message,
    required this.data,
  });

  factory CoreDataSourceResponse.fromJson(Map<String, dynamic> json) {
    return CoreDataSourceResponse(
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList() ??
          const [],
    );
  }

  bool get isAllowed => data.isNotEmpty && data.first;
}