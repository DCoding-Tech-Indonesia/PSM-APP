abstract class TimetableEvent {}

class PageDashboardLoad extends TimetableEvent {}

class LocationLoaded extends TimetableEvent {
  final double lat;
  final double long;

  LocationLoaded({
    required this.lat,
    required this.long,
  });
}

class SelectKoridor extends TimetableEvent {
  final int id;
  final String namaKoridor;

  SelectKoridor(this.id, this.namaKoridor);
}

class SelectBus extends TimetableEvent {
  final int id;
  final String noUnit;

  SelectBus(this.id, this.noUnit);
}

class CheckInTimetable extends TimetableEvent {}

class ResetInput extends TimetableEvent {}