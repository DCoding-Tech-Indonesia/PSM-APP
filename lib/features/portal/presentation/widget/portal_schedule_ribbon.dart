import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

class PortalScheduleRibbon extends StatefulWidget {
  const PortalScheduleRibbon({super.key});

  @override
  State<PortalScheduleRibbon> createState() => _PortalScheduleRibbonState();
}

class _PortalScheduleRibbonState extends State<PortalScheduleRibbon> {
  DateTime selectedDate = DateTime.now();
  late ScrollController _scrollController;
  final double itemWidth = 60.0;
  final double itemMargin = 10.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerToday();
    });
  }

  void _centerToday() {
    if (!_scrollController.hasClients) return;

    // Today index in our 7-day list is now 3 because it's in the middle (3 days before, 3 days after)
    final todayIndex = 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final fullItemWidth = itemWidth + itemMargin;

    double offset =
        (todayIndex * fullItemWidth) -
        (screenWidth / 2) +
        (fullItemWidth / 2) +
        16;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (offset < 0) offset = 0;
    if (offset > maxScroll) offset = maxScroll;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutExpo,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();

    // Start from now - 3 days as requested for 7 days (today in the middle)
    final List<DateTime> weekDates = List.generate(
      7,
      (index) =>
          now.subtract(const Duration(days: 3)).add(Duration(days: index)),
    );

    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final unselectedItemColor = isDark
        ? const Color(0xFF2C2C2C)
        : Colors.grey[200];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey[300];

    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        List<ScheduleModel> schedules = [];
        // if (state is AttendanceLoaded) {
        //   schedules = state.schedules;
        // }

        // Find schedule for selected date
        ScheduleModel? currentSchedule;
        try {
          currentSchedule = schedules.firstWhere(
            (s) => DateUtils.isSameDay(DateTime.parse(s.tanggal), selectedDate),
          );
        } catch (_) {
          currentSchedule = null;
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Jadwal Mingguan',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('MMMM yyyy').format(selectedDate),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = weekDates[index];
                  final isSelected = DateUtils.isSameDay(date, selectedDate);
                  final isToday = DateUtils.isSameDay(date, now);

                  // Check if this date has a schedule
                  bool hasSchedule = schedules.any(
                    (s) => DateUtils.isSameDay(DateTime.parse(s.tanggal), date),
                  );

                  return GestureDetector(
                    onTap: () => setState(() => selectedDate = date),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: itemWidth,
                          height: 85,
                          margin: EdgeInsets.only(right: itemMargin),
                          decoration: BoxDecoration(
                            color: isSelected ? null : unselectedItemColor,
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : (isToday
                                        ? theme.primaryColor.withValues(
                                            alpha: 0.5,
                                          )
                                        : borderColor!),
                              width: isSelected || isToday ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE').format(date).toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.grey[500],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (hasSchedule)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: currentSchedule != null
                    ? Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        DateUtils.isSameDay(selectedDate, now)
                                            ? 'SHIFT HARI INI'
                                            : 'SHIFT TERJADWAL',
                                        style: TextStyle(
                                          color: theme.primaryColor.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentSchedule.shift.name,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        currentSchedule.lokasi.namaLokasi,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: currentSchedule.isCadangan
                                  ? Colors.amber.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    (currentSchedule.isCadangan
                                            ? Colors.amber
                                            : Colors.green)
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                currentSchedule.isCadangan
                                    ? 'CADANGAN'
                                    : 'UTAMA',
                                style: TextStyle(
                                  color: currentSchedule.isCadangan
                                      ? Colors.amber[700]
                                      : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: isDark ? Colors.white38 : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tidak ada jadwal',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
