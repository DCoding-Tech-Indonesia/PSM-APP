import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttendanceData extends AttendanceEvent {}
class UpdateTime extends AttendanceEvent {}
class RefreshLocation extends AttendanceEvent {}
class CheckInRequested extends AttendanceEvent {}
class CheckOutRequested extends AttendanceEvent {}
class DebugStoredDataRequested extends AttendanceEvent {}

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final String currentDate;
  final String currentTime;
  final bool isCheckedIn;
  final String checkInTime;
  final String checkOutTime;
  final bool isLoading;
  final bool canCheckIn;
  final String locationStatus;
  final String distanceFromOffice;
  final AttendanceStats stats;
  final List<AttendanceRecord> history;

  AttendanceLoaded({
    required this.currentDate,
    required this.currentTime,
    required this.isCheckedIn,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLoading,
    required this.canCheckIn,
    required this.locationStatus,
    required this.distanceFromOffice,
    required this.stats,
    required this.history,
  });

  @override
  List<Object?> get props => [
    currentDate,
    currentTime,
    isCheckedIn,
    checkInTime,
    checkOutTime,
    isLoading,
    canCheckIn,
    locationStatus,
    distanceFromOffice,
    stats,
    history,
  ];

  AttendanceLoaded copyWith({
    String? currentDate,
    String? currentTime,
    bool? isCheckedIn,
    String? checkInTime,
    String? checkOutTime,
    bool? isLoading,
    bool? canCheckIn,
    String? locationStatus,
    String? distanceFromOffice,
    AttendanceStats? stats,
    List<AttendanceRecord>? history,
  }) {
    return AttendanceLoaded(
      currentDate: currentDate ?? this.currentDate,
      currentTime: currentTime ?? this.currentTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isLoading: isLoading ?? this.isLoading,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      locationStatus: locationStatus ?? this.locationStatus,
      distanceFromOffice: distanceFromOffice ?? this.distanceFromOffice,
      stats: stats ?? this.stats,
      history: history ?? this.history,
    );
  }
}
