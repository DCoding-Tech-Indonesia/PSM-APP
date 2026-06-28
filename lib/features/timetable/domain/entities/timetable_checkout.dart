import 'package:equatable/equatable.dart';

class TimetableCheckout extends Equatable{
  final int idTimeTableRitase;
  final double lat;
  final double long;

  const TimetableCheckout({
    required this.idTimeTableRitase,
    required this.long,
    required this.lat,
  });

  Map<String, dynamic> toJson() => {
    "idTimeTableRitase": idTimeTableRitase,
    "lon": long,
    "lat": lat,
  };

  TimetableCheckout copyWith({
    int? idTimeTableRitase,
    double? long,
    double? lat,
  }) {
    return TimetableCheckout(
      idTimeTableRitase: idTimeTableRitase ?? this.idTimeTableRitase,
      long: long ?? this.long,
      lat: lat ?? this.lat,
    );
  }

  @override
  List<Object?> get props => [
    idTimeTableRitase,
    long,
    lat,
  ];
}