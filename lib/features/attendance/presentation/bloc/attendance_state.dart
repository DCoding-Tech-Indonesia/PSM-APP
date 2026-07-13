import 'package:equatable/equatable.dart';
import 'package:travis/features/attendance/data/models/attendance_record.dart';
import 'package:travis/features/attendance/data/models/schedule_model.dart';

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
  CheckInRequested();

  @override
  List<Object?> get props => [];
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
  final String? successMessage;
  final AttendanceStats stats;
  final List<AttendanceRecord> history;
  final List<ScheduleModel> schedules;
  final List<ScheduleModel> schedulePerMonth;
  final String radiusInfo;
  final String shift;
  final bool isCadangan;
  // final List<dynamic> bus;
  final List<dynamic> replacementSchedules;

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
    this.successMessage,
    required this.stats,
    required this.history,
    this.schedules = const [],
    this.schedulePerMonth = const [],
    this.radiusInfo = '100m',
    this.shift = '',
    this.isCadangan = false,
    // required this.bus,
    this.replacementSchedules = const [],
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
    successMessage,
    stats,
    history,
    schedules,
    schedulePerMonth,
    radiusInfo,
    shift,
    isCadangan,
    // bus,
    replacementSchedules,
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
    String? successMessage,
    AttendanceStats? stats,
    List<AttendanceRecord>? history,
    List<ScheduleModel>? schedules,
    List<ScheduleModel>? schedulePerMonth,
    String? radiusInfo,
    String? shift,
    bool? isCadangan,
    // List<dynamic>? bus,
    List<dynamic>? replacementSchedules,
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
      successMessage: successMessage,
      stats: stats ?? this.stats,
      history: history ?? this.history,
      schedules: schedules ?? this.schedules,
      schedulePerMonth: schedulePerMonth ?? this.schedulePerMonth,
      radiusInfo: radiusInfo ?? this.radiusInfo,
      shift: shift ?? this.shift,
      isCadangan: isCadangan ?? this.isCadangan,
      // bus: bus ?? this.bus,
      replacementSchedules: replacementSchedules ?? this.replacementSchedules,
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
