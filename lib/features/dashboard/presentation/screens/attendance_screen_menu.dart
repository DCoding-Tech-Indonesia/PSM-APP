import 'package:flutter/material.dart';
import 'package:psm_mobile/features/dashboard/presentation/widgets/attendance/date_picker_button.dart';

class AttendanceScreenMenu extends StatelessWidget {
  const AttendanceScreenMenu({super.key});

  String getDayName(int weekday) {
    const days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
    return days[weekday - 1];
  }

  List<DateTime> generateMonthDates(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(
      daysInMonth,
          (index) => DateTime(year, month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dates = generateMonthDates(2026, 3); // Maret 2026
    final today = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Attendance Report", style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dates.map((date) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DatePickerButton(
                      date: date.day.toString(),
                      day: getDayName(date.weekday),
                      active: date.day == today.day &&
                          date.month == today.month &&
                          date.year == today.year,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}