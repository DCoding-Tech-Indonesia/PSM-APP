class NextRitaseResponse {
  final double? ritaseKe;
  final bool? isLastRitase;

  const NextRitaseResponse({
    this.ritaseKe,
    this.isLastRitase,
  });

  factory NextRitaseResponse.fromJson(Map<String, dynamic> json) {
    return NextRitaseResponse(
      ritaseKe: (json['ritaseKe'] as num?)?.toDouble(),
      isLastRitase: json['isLastRitase'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ritaseKe': ritaseKe,
      'isLastRitase': isLastRitase,
    };
  }
}