import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:psm_mobile/core/helper/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  Timer? _timer;
  final AttendanceRepository repository;
  final LocationService locationService;

  AttendanceBloc({required this.repository, required this.locationService})
    : super(AttendanceInitial()) {
    on<LoadAttendanceData>(_onLoadData);
    on<UpdateTime>(_onUpdateTime);
    on<RefreshLocation>(_onRefreshLocation);
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
    on<RefreshAttendanceData>(_onRefreshData);

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateTime());
    });
  }

  Future<void> _onLoadData(
    LoadAttendanceData event,
    Emitter<AttendanceState> emit,
  ) async {
    final now = DateTime.now();
    final initialState = AttendanceLoaded(
      userId: event.userId,
      currentDate: DateFormat('EEEE, dd MMM yyyy').format(now),
      currentTime: DateFormat('HH:mm:ss').format(now),
      isCheckedIn: false,
      checkInTime: '',
      checkOutTime: '',
      isLoading: true,
      canCheckIn: false,
      locationStatus: 'Mencari lokasi...',
      distanceFromOffice: '0m',
      stats: AttendanceStats(),
      history: [],
      schedules: [],
      schedulePerMonth: [],
      bus: [],
      replacementSchedules: [],
    );
    if (isClosed) return;
    emit(initialState);

    await _fetchHistoryAndEmit(event.userId, emit, initialState);

    if (isClosed) return;
    add(RefreshLocation());
  }

  Future<void> _onRefreshData(
    RefreshAttendanceData event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      emit(s.copyWith(isLoading: true));
      await _fetchHistoryAndEmit(s.userId, emit, s);
      add(RefreshLocation());
    }
  }

  Future<void> _fetchHistoryAndEmit(
    String userId,
    Emitter<AttendanceState> emit,
    AttendanceLoaded currentState, {
    String? successMessage,
  }) async {
    try {
      final uId = int.tryParse(userId) ?? 0;
      final now = DateTime.now();

      // Calculate start and end date for 7 days schedule (Today in the middle)
      // final startDate = DateFormat(
      //   'yyyy-MM-dd',
      // ).format(now.subtract(const Duration(days: 0)));
      // final endDate = DateFormat(
      //   'yyyy-MM-dd',
      // ).format(now.add(const Duration(days: 100)));

      final startDate = DateFormat('yyyy-MM-dd').format(now);
      // Mengambil endDate 30 hari dari hari ini
      final endDate = DateFormat(
        'yyyy-MM-dd',
      ).format(now.add(const Duration(days: 30)));

      // Removed heavy 11-month fetch for schedulePerMonth

      // Fetch History, Stats, and Schedules in parallel
      final results = await Future.wait([
        repository.getHistory(uId, 7),
        repository.getStats(userId: uId, month: now.month, year: now.year),
        repository.getSchedules(
          userId: uId,
          startDate: startDate,
          endDate: endDate,
        ),
        repository.getBus(),
      ]);

      final List<AttendanceRecord> history =
          results[0] as List<AttendanceRecord>;
      final Map<String, dynamic>? statsResponse =
          results[1] as Map<String, dynamic>?;
      final List<ScheduleModel> schedules = results[2] as List<ScheduleModel>;
      final List<dynamic> bus = results[3] as List<dynamic>;
      final List<ScheduleModel> schedulePerMonth = [];
      final List<dynamic> replacementSchedules = [];

      AttendanceStats stats = currentState.stats;
      if (statsResponse != null &&
          statsResponse['data'] is List &&
          (statsResponse['data'] as List).isNotEmpty) {
        final data = statsResponse['data'][0];
        stats = AttendanceStats(
          totalDays: data['totalJadwal'] ?? 0,
          presentDays: data['totalHadir'] ?? 0,
          lateDays: data['totalTerlambat'] ?? 0,
          absentDays: data['totalAbsen'] ?? 0,
        );
      }

      bool isCheckedIn = false;
      String checkInTime = '';
      String checkOutTime = '';

      if (history.isNotEmpty) {
        final last = history[0];
        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final lastDateStr = last.checkIn != null
            ? DateFormat('yyyy-MM-dd').format(last.checkIn!)
            : '';

        if (todayStr == lastDateStr) {
          isCheckedIn = last.checkIn != null;
          checkInTime = last.checkInTime;
          checkOutTime = last.checkOut != null ? last.checkOutTime : '';
        }
      }

      emit(
        currentState.copyWith(
          isLoading: false,
          history: history,
          stats: stats,
          schedules: schedules,
          schedulePerMonth: schedulePerMonth,
          isCheckedIn: isCheckedIn,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          bus: bus,
          replacementSchedules: replacementSchedules,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      if (!isClosed) {
        emit(currentState.copyWith(isLoading: false));
      }
    }
  }

  void _onUpdateTime(UpdateTime event, Emitter<AttendanceState> emit) {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      final now = DateTime.now();
      emit(
        s.copyWith(
          currentTime: DateFormat('HH:mm:ss').format(now),
          currentDate: DateFormat('EEEE, dd MMM yyyy').format(now),
        ),
      );
    }
  }

  Future<void> _onRefreshLocation(
    RefreshLocation event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      emit(s.copyWith(isLoading: true));

      try {
        final position = await locationService.getCurrentLocation();

        if (position != null) {
          final detail = await repository.getAttendanceDetail(
            userId: int.tryParse(s.userId) ?? 0,
            lat: position.latitude,
            lon: position.longitude,
          );

          if (detail != null && detail['data'] is List) {
            final List dataList = detail['data'];
            if (dataList.isNotEmpty) {
              final info = dataList[0];
              String jarakStr = info['jarak'] ?? '0m';
              String radiusStr = info['radius'] ?? '0m';
              String namaLokasi =
                  info['namaLokasi'] ?? 'Lokasi tidak diketahui';
              bool isCadangan = info['isCadangan'] ?? false;

              double jarakVal = _parseDistanceValue(jarakStr);
              double radiusVal = _parseDistanceValue(radiusStr);
              bool inRadius = jarakVal <= radiusVal;

              emit(
                s.copyWith(
                  isLoading: false,
                  distanceFromOffice: jarakStr,
                  canCheckIn: inRadius && !position.isMocked,
                  isMocked: position.isMocked,
                  locationStatus: position.isMocked
                      ? 'FAKE GPS TERDETEKSI!'
                      : namaLokasi,
                  radiusInfo: radiusStr,
                  isCadangan: isCadangan,
                  bus: s.bus,
                  replacementSchedules: s.replacementSchedules,
                ),
              );
            } else {
              throw 'Detail lokasi tidak ditemukan dalam respons';
            }
          } else {
            throw 'Gagal mendapatkan detail lokasi dari server';
          }
        }
      } catch (e) {
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        bool isFakeGps = errorMsg.contains('Fake GPS');

        emit(
          s.copyWith(
            isLoading: false,
            locationStatus: errorMsg,
            canCheckIn: false,
            isMocked: isFakeGps,
            distanceFromOffice: '0m',
            radiusInfo: '0m',
            isCadangan: false,
            bus: s.bus,
            replacementSchedules: s.replacementSchedules,
          ),
        );
      }
    }
  }

  double _parseDistanceValue(String text) {
    final match = RegExp(r"([0-9.]+)").firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  Future<void> _onCheckIn(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      if (!s.canCheckIn) return;

      emit(s.copyWith(isLoading: true));

      try {
        final position = await locationService.getCurrentLocation();
        if (position == null) throw 'Gagal mendapatkan lokasi';

        final request = AttendanceRequest(
          idUser: int.tryParse(s.userId) ?? 0,
          lokasiLat: position.latitude,
          lokasiLong: position.longitude,
          idBus: event.busId,
        );

        final success = await repository.submitAttendance(request);

        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('active_bus_id', event.busId);

          // Re-fetch everything to ensure stats and history are synchronized
          await _fetchHistoryAndEmit(s.userId, emit, s, successMessage: 'Check-in berhasil!');
        } else {
          emit(
            s.copyWith(
              isLoading: false,
              errorMessage: 'Gagal melakukan check-in. Silakan coba lagi.',
            ),
          );
        }
      } catch (e) {
        emit(s.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onCheckOut(
    CheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final s = state as AttendanceLoaded;
      if (!s.isCheckedIn || s.checkOutTime.isNotEmpty) return;

      emit(s.copyWith(isLoading: true));

      try {
        final position = await locationService.getCurrentLocation();
        if (position == null) throw 'Gagal mendapatkan lokasi';

        final prefs = await SharedPreferences.getInstance();
        final busId = prefs.getInt('active_bus_id') ?? 0;

        final request = AttendanceRequest(
          idUser: int.tryParse(s.userId) ?? 0,
          lokasiLat: position.latitude,
          lokasiLong: position.longitude,
          idBus: busId,
        );

        final success = await repository.submitAttendance(request);

        if (success) {
          // Re-fetch everything to ensure stats and history are synchronized
          await _fetchHistoryAndEmit(s.userId, emit, s, successMessage: 'Check-out berhasil!');
        } else {
          emit(
            s.copyWith(
              isLoading: false,
              errorMessage: 'Gagal melakukan check-out. Silakan coba lagi.',
            ),
          );
        }
      } catch (e) {
        emit(s.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
