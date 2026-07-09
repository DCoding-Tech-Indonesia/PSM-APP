abstract class TimetableEvent {}

class PageDashboardLoad extends TimetableEvent {}

class PageDashboardLoadNextPage extends TimetableEvent {}

class PageHistoryLoad extends TimetableEvent {}

class PageHistoryLoadNextPage extends TimetableEvent {}

class LocationLoaded extends TimetableEvent {
  final double lat;
  final double long;

  LocationLoaded({
    required this.lat,
    required this.long,
  });
}

class CheckInTimetable extends TimetableEvent {}

class CheckOutTimetable extends TimetableEvent {}