import 'package:flutter/material.dart';
import 'package:travis/features/attendance/presentation/bloc/attendance_state.dart';

class DateTimeCard extends StatelessWidget {
  final AttendanceLoaded state;

  const DateTimeCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final double screenWidth = size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      padding: EdgeInsets.fromLTRB(
        size.width * 0.001,
        0,
        size.width * 0.001,
        size.width * 0.03,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: (screenWidth * 0.02).clamp(8.0, 12.0),
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all((screenWidth * 0.02).clamp(6.0, 8.0)),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(
                    (screenWidth * 0.03).clamp(8.0, 12.0),
                  ),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: (screenWidth * 0.045).clamp(16.0, 20.0),
                ),
              ),
              SizedBox(width: (screenWidth * 0.02).clamp(6.0, 10.0)),
              Flexible(
                child: Text(
                  state.currentDate,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.035).clamp(13.0, 15.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (screenWidth * 0.03).clamp(8.0, 12.0),
              vertical: (screenWidth * 0.02).clamp(6.0, 8.0),
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black26
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                (screenWidth * 0.03).clamp(8.0, 12.0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: (screenWidth * 0.04).clamp(14.0, 18.0),
                ),
                SizedBox(width: (screenWidth * 0.02).clamp(4.0, 8.0)),
                Text(
                  state.currentTime,
                  style: TextStyle(
                    fontSize: (screenWidth * 0.045).clamp(16.0, 18.0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
