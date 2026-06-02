import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
// import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttendanceData extends AttendanceEvent {
  final String userId;
  LoadAttendanceData({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateTime extends AttendanceEvent {}

class RefreshLocation extends AttendanceEvent {}

class CheckInRequested extends AttendanceEvent {
  final int shiftId;
  final int busId;

  CheckInRequested({required this.shiftId, required this.busId});

  @override
  List<Object?> get props => [shiftId, busId];
}

class CheckOutRequested extends AttendanceEvent {}

class RefreshAttendanceData extends AttendanceEvent {}

class DebugStoredDataRequested extends AttendanceEvent {}

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final String userId;
  final String currentDate;
  final String currentTime;
  final bool isCheckedIn;
  final String checkInTime;
  final String checkOutTime;
  final bool isLoading;
  final bool canCheckIn;
  final bool isMocked;
  final String locationStatus;
  final String distanceFromOffice;
  final String? errorMessage;
  final List<AttendanceRecord> history;
  // final AttendanceStats stats;
  // final List<ScheduleModel> schedules;
  final String radiusInfo;
  final bool isCadangan;
  final List<dynamic> shifts;
  final List<dynamic> bus;

  AttendanceLoaded({
    required this.userId,
    required this.currentDate,
    required this.currentTime,
    required this.isCheckedIn,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLoading,
    required this.canCheckIn,
    this.isMocked = false,
    required this.locationStatus,
    required this.distanceFromOffice,
    this.errorMessage,
    required this.history,
    // required this.stats,
    // this.schedules = const [],
    this.radiusInfo = '100m',
    this.isCadangan = false,
    required this.shifts,
    required this.bus,
  });

  @override
  List<Object?> get props => [
    userId,
    currentDate,
    currentTime,
    isCheckedIn,
    checkInTime,
    checkOutTime,
    isLoading,
    canCheckIn,
    isMocked,
    locationStatus,
    distanceFromOffice,
    errorMessage,
    history,
    // stats,
    // schedules,
    radiusInfo,
    isCadangan,
    shifts,
    bus,
  ];

  AttendanceLoaded copyWith({
    String? userId,
    String? currentDate,
    String? currentTime,
    bool? isCheckedIn,
    String? checkInTime,
    String? checkOutTime,
    bool? isLoading,
    bool? canCheckIn,
    bool? isMocked,
    String? locationStatus,
    String? distanceFromOffice,
    String? errorMessage,
    List<AttendanceRecord>? history,
    // AttendanceStats? stats,
    // List<ScheduleModel>? schedules,
    String? radiusInfo,
    bool? isCadangan,
    List<dynamic>? shifts,
    List<dynamic>? bus,
  }) {
    return AttendanceLoaded(
      userId: userId ?? this.userId,
      currentDate: currentDate ?? this.currentDate,
      currentTime: currentTime ?? this.currentTime,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isLoading: isLoading ?? this.isLoading,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      isMocked: isMocked ?? this.isMocked,
      locationStatus: locationStatus ?? this.locationStatus,
      distanceFromOffice: distanceFromOffice ?? this.distanceFromOffice,
      errorMessage: errorMessage,
      history: history ?? this.history,
      // stats: stats ?? this.stats,
      // schedules: schedules ?? this.schedules,
      radiusInfo: radiusInfo ?? this.radiusInfo,
      isCadangan: isCadangan ?? this.isCadangan,
      shifts: shifts ?? this.shifts,
      bus: bus ?? this.bus,
    );
  }
}

class AttendanceStats extends Equatable {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;

  const AttendanceStats({
    this.totalDays = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.absentDays = 0,
  });

  @override
  List<Object?> get props => [totalDays, presentDays, lateDays, absentDays];
}
