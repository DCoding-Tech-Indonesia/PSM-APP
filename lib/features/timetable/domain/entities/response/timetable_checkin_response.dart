import 'package:equatable/equatable.dart';

class TimetableCheckinResponse extends Equatable {
  final bool success;
  final String message;

  const TimetableCheckinResponse({
    required this.success,
    required this.message,
  });

  factory TimetableCheckinResponse.fromJson(Map<String, dynamic> json) {
    return TimetableCheckinResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };

  TimetableCheckinResponse copyWith({
    bool? success,
    String? message,
  }) {
    return TimetableCheckinResponse(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [success, message];
}