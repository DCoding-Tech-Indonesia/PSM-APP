import 'package:equatable/equatable.dart';

class TimetableCheckinResponse extends Equatable {
  final bool status;
  final String message;

  const TimetableCheckinResponse({
    required this.status,
    required this.message,
  });

  factory TimetableCheckinResponse.fromJson(Map<String, dynamic> json) {
    return TimetableCheckinResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };

  TimetableCheckinResponse copyWith({
    bool? status,
    String? message,
  }) {
    return TimetableCheckinResponse(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}