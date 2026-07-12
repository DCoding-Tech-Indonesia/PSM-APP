import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travis/core/helper/date_time_helper.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/storage/secure_storage.dart';

class CoreDateTimeWidget extends StatefulWidget {
  final String? noUnit;
  final String? namaKoridor;
  final double? ritaseKe;
  final bool? isLastRitase;
  final bool showScheduleInfo;
  final bool? isAllowCheckIn;
  final bool? isAllowCheckOut;

  const CoreDateTimeWidget({
    super.key,
    this.noUnit,
    this.namaKoridor,
    this.ritaseKe,
    this.isLastRitase,
    this.showScheduleInfo = false,
    this.isAllowCheckIn,
    this.isAllowCheckOut,
  });

  @override
  State<CoreDateTimeWidget> createState() => _CoreDateTimeWidgetState();
}

class _CoreDateTimeWidgetState extends State<CoreDateTimeWidget> {
  late DateTime _now;
  Timer? _timer;
  String? _shiftName;
  bool _isLoadingShift = true;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _fetchShiftData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
    // Refresh shift data setiap 5 menit
    Timer.periodic(const Duration(minutes: 5), (_) {
      _fetchShiftData();
    });
  }

  Future<void> _fetchShiftData() async {
    try {
      final secureStorage = SecureStorageService();
      final userId = await secureStorage.readUserId();

      if (userId == null) return;

      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        // Location failed, use default coordinates
        position = null;
      }

      final dio = DioClient().instance;
      final response = await dio.get(
        '/absensi/detail',
        queryParameters: {
          'userId': userId,
          'lat': position?.latitude ?? -0.8502857,
          'lon': position?.longitude ?? 100.379713,
        },
      );

      if (response.data['status'] == true) {
        final data = response.data['data'] as List;
        if (data.isNotEmpty) {
          setState(() {
            _shiftName = data[0]['shift'] as String?;
            _isLoadingShift = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingShift = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final hasShift = _shiftName != null && _shiftName!.isNotEmpty;
    final hasScheduleInfo =
        widget.showScheduleInfo &&
        widget.noUnit != null &&
        widget.noUnit!.isNotEmpty;

    // Check if shift is valid (Shift Pagi or Shift Siang)
    final isValidShift =
        hasShift &&
        (_shiftName!.toLowerCase().contains('pagi') ||
            _shiftName!.toLowerCase().contains('siang'));

    // Check if both buttons are disabled (explicit false check)
    // This indicates no active checkin/session, should ALWAYS be red
    final bothButtonsDisabled =
        (widget.isAllowCheckIn == false && widget.isAllowCheckOut == false);

    // Special case: if showScheduleInfo is true but no schedule data, force red
    final noScheduleData = widget.showScheduleInfo == true && !hasScheduleInfo;

    // Determine card color:
    // PRIORITY 1: If both buttons disabled (no checkin) -> ALWAYS RED regardless of shift
    // PRIORITY 2: If no schedule data when expected -> RED
    // PRIORITY 3: If invalid shift -> RED
    // Otherwise -> BLUE
    final isRedCard = bothButtonsDisabled || noScheduleData || !isValidShift;

    // Define gradient colors
    final gradientColors = isRedCard
        ? [const Color(0xFFE53935), const Color(0xFFEF5350)]
        : [const Color(0xFF1565C0), const Color(0xFF1E88E5)];

    final shadowColor = isRedCard
        ? const Color(0xFFE53935)
        : const Color(0xFF1565C0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Time + Shift Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _timeString,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateTimeHelper.formatEEEDDMMYY(_now),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: hasShift
                            ? const Color(0xFF00E676)
                            : Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (hasShift
                                        ? const Color(0xFF00E676)
                                        : Colors.white)
                                    .withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLoadingShift
                          ? '...'
                          : (hasShift ? _shiftName!.toUpperCase() : 'NO SHIFT'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Row 2: Schedule Info (Unit + Koridor + Ritase) - Integrated Design
          if (hasScheduleInfo) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                // Bus Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Unit + Koridor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit ${widget.noUnit}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.namaKoridor?.isNotEmpty == true
                            ? widget.namaKoridor!
                            : 'Memuat koridor...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Ritase Badge
                if (widget.ritaseKe != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'R${widget.ritaseKe! % 1 == 0 ? widget.ritaseKe!.toInt() : widget.ritaseKe}${widget.isLastRitase == true ? " •" : ""}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
