import 'package:flutter/material.dart';

class DatePickerButton extends StatelessWidget {
  const DatePickerButton({
    super.key,
    required this.date,
    required this.day,
    required this.active,
  });

  final String date;
  final String day;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: active ? theme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(color: active ? Colors.white70 : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
              color: active ? Colors.white70 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
