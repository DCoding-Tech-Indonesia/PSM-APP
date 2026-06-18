import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';

class ScheduleCalendarScreen extends StatefulWidget {
  final String userId;

  const ScheduleCalendarScreen({super.key, required this.userId});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  bool _isLoading = true;
  List<ScheduleModel> _schedules = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _fetchSchedulesForMonth(_currentMonth);
  }

  Future<void> _fetchSchedulesForMonth(DateTime month) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(DioClient()),
      );

      final startDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(month.year, month.month, 1));
      // Kita fetch jadwal sebulan penuh
      final endDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(month.year, month.month + 1, 0));

      final schedules = await repository.getSchedules(
        userId: int.tryParse(widget.userId) ?? 0,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchSchedulesForMonth(_currentMonth);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchSchedulesForMonth(_currentMonth);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _getDaysInMonth(_currentMonth);
    // Find the weekday of the first day to add padding to the grid
    final firstWeekday = days.first.weekday;
    // Sunday is 7, Monday is 1. We start week on Monday:
    final offset = firstWeekday - 1;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 100) {
              // Swipe Right -> Bulan sebelumnya
              _previousMonth();
            } else if (details.primaryVelocity! < -100) {
              // Swipe Left -> Bulan berikutnya
              _nextMonth();
            }
          },
          child: Column(
            children: [
              // Month navigation
              CoreHeader(
                title: 'Jadwal Bulanan',
                subtitle: 'Lihat jadwal shift kerja bulanan Anda',
                showBackButton: true,
                onBackPressed: () => context.pop(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              // Days of week header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Calendar Grid
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: days.length + offset,
                    itemBuilder: (context, index) {
                      if (index < offset) {
                        return const SizedBox.shrink();
                      }

                      final dayDate = days[index - offset];
                      final dateString = DateFormat(
                        'yyyy-MM-dd',
                      ).format(dayDate);

                      // Find schedule for this day
                      final scheduleForDay = _schedules
                          .where((s) => s.tanggal == dateString)
                          .toList();

                      final isToday =
                          dayDate.year == DateTime.now().year &&
                          dayDate.month == DateTime.now().month &&
                          dayDate.day == DateTime.now().day;

                      final isSelected =
                          _selectedDay != null &&
                          dayDate.year == _selectedDay!.year &&
                          dayDate.month == _selectedDay!.month &&
                          dayDate.day == _selectedDay!.day;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (_selectedDay != null &&
                                _selectedDay!.year == dayDate.year &&
                                _selectedDay!.month == dayDate.month &&
                                _selectedDay!.day == dayDate.day) {
                              _selectedDay =
                                  null; // Deselect jika hari yang sama diklik lagi
                            } else {
                              _selectedDay = dayDate;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orange.withValues(alpha: 0.15)
                                : isToday
                                ? theme.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.orange
                                  : isToday
                                  ? theme.primaryColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${dayDate.day}',
                                style: TextStyle(
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isToday ? theme.primaryColor : null,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (scheduleForDay.isNotEmpty)
                                Expanded(
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: scheduleForDay.length,
                                    itemBuilder: (ctx, i) {
                                      final sched = scheduleForDay[i];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 1,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(
                                            alpha: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          sched.shift.name,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              Text(
                                isToday ? 'Hari ini' : '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _selectedDay == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Pilih tanggal pada kalender untuk melihat detail jadwal',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jadwal: ${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...() {
                            final selectedDateString = DateFormat(
                              'yyyy-MM-dd',
                            ).format(_selectedDay!);
                            final schedulesOnDay = _schedules
                                .where((s) => s.tanggal == selectedDateString)
                                .toList();

                            if (schedulesOnDay.isEmpty) {
                              return [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Tidak ada jadwal pada tanggal ini.',
                                  ),
                                ),
                              ];
                            }

                            return schedulesOnDay.map((s) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.shift.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            s.lokasi.namaLokasi,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                          }(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
