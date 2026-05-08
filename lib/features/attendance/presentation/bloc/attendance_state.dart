import 'package:equatable/equatable.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';

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
class CheckInRequested extends AttendanceEvent {}
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
  final AttendanceStats stats;
  final List<AttendanceRecord> history;
  final String radiusInfo;
  final bool isCadangan;

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
    required this.stats,
    required this.history,
    this.radiusInfo = '100m',
    this.isCadangan = false,
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
    stats,
    history,
    radiusInfo,
    isCadangan,
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
    AttendanceStats? stats,
    List<AttendanceRecord>? history,
    String? radiusInfo,
    bool? isCadangan,
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
      stats: stats ?? this.stats,
      history: history ?? this.history,
      radiusInfo: radiusInfo ?? this.radiusInfo,
      isCadangan: isCadangan ?? this.isCadangan,
    );
  }
}

