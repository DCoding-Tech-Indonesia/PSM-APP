import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/core/helper/location_service.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  Timer? _timer;
  
  // Office Location (Contoh: Padang)
  static const double OFFICE_LAT = -6.228483167113237;
  static const double OFFICE_LNG = 106.83357678889395;
  static const double RADIUS = 100.0;

  AttendanceBloc() : super(AttendanceInitial()) {
    on<LoadAttendanceData>(_onLoadData);
    on<UpdateTime>(_onUpdateTime);
    on<RefreshLocation>(_onRefreshLocation);
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
    
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateTime());
    });
  }

  Future<void> _onLoadData(LoadAttendanceData event, Emitter<AttendanceState> emit) async {
    // Simulasi loading data awal
    final now = DateTime.now();
    emit(AttendanceLoaded(
      currentDate: DateFormat('EEEE, dd MMM yyyy').format(now),
      currentTime: DateFormat('HH:mm:ss').format(now),
      isCheckedIn: false,
      checkInTime: '',
      checkOutTime: '',
      isLoading: false,
      canCheckIn: false,
      locationStatus: 'Mencari lokasi...',
      distanceFromOffice: '0m',
      stats: AttendanceStats(totalDays: 20, presentDays: 18, lateDays: 2, absentDays: 0),
      history: [],
    ));
    
    add(RefreshLocation());
  }

  void _onUpdateTime(UpdateTime event, Emitter<AttendanceState> emit) {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      final now = DateTime.now();
      emit(s.copyWith(
        currentTime: DateFormat('HH:mm:ss').format(now),
        currentDate: DateFormat('EEEE, dd MMM yyyy').format(now),
      ));
    }
  }

  Future<void> _onRefreshLocation(RefreshLocation event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      emit(s.copyWith(isLoading: true));

      try {
        final position = await LocationService().getCurrentLocation();
        
        if (position != null) {
          double distance = LocationService().calculateDistance(
            position.latitude,
            position.longitude,
            OFFICE_LAT,
            OFFICE_LNG,
          );

          bool inRadius = distance <= RADIUS;
          emit(s.copyWith(
            isLoading: false,
            distanceFromOffice: '${distance.toInt()}m',
            canCheckIn: inRadius && !position.isMocked,
            isMocked: position.isMocked,
            locationStatus: position.isMocked 
                ? 'Fake GPS Terdeteksi!' 
                : (inRadius ? 'Berada di area kantor' : 'Di luar area kantor'),
          ));
        }
      } catch (e) {
        final errorMsg = e.toString();
        bool isFakeGps = errorMsg.contains('Fake GPS');
        
        emit(s.copyWith(
          isLoading: false, 
          locationStatus: errorMsg, 
          canCheckIn: false,
          isMocked: isFakeGps,
        ));
      }
    }
  }

  Future<void> _onCheckIn(CheckInRequested event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      if (!s.canCheckIn) return;
      
      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm:ss').format(now);
      
      final newRecord = AttendanceRecord(
        timestamp: now,
        checkIn: timeStr,
        date: s.currentDate,
      );

      emit(s.copyWith(
        isCheckedIn: true,
        checkInTime: timeStr,
        history: [newRecord, ...s.history],
      ));
    }
  }

  Future<void> _onCheckOut(CheckOutRequested event, Emitter<AttendanceState> emit) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      if (!s.isCheckedIn || s.checkOutTime.isNotEmpty) return;

      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm:ss').format(now);

      List<AttendanceRecord> updatedHistory = List.from(s.history);
      if (updatedHistory.isNotEmpty) {
        final last = updatedHistory[0];
        updatedHistory[0] = AttendanceRecord(
          timestamp: last.timestamp,
          checkIn: last.checkIn,
          checkOut: timeStr,
          date: last.date,
        );
      }

      emit(s.copyWith(
        checkOutTime: timeStr,
        history: updatedHistory,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
