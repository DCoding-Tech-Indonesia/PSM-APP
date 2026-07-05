class CoreStatusAndMessageResponse {
  final bool status;
  final String message;

  const CoreStatusAndMessageResponse({
    required this.status,
    required this.message,
  });

  factory CoreStatusAndMessageResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CoreStatusAndMessageResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}