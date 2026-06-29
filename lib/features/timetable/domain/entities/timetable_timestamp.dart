class TimetableTimestamp {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  const TimetableTimestamp({
    required this.hour,
    required this.minute,
    required this.second,
    required this.nano,
  });

  factory TimetableTimestamp.fromJson(Map<String, dynamic> json) {
    return TimetableTimestamp(
      hour: json['hour'],
      minute: json['minute'],
      second: json['second'],
      nano: json['nano'],
    );
  }

  Map<String, dynamic> toJson() => {
    "hour": hour,
    "minute": minute,
    "second": second,
    "nano": nano,
  };

  TimetableTimestamp copyWith({
    int? hour,
    int? minute,
    int? second,
    int? nano,
  }) {
    return TimetableTimestamp(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      nano: nano ?? this.nano,
    );
  }
}
