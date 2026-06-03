import 'package:flutter/material.dart';

class CoreSelectedDropdownIndicator extends StatelessWidget {
  const CoreSelectedDropdownIndicator({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    if (active) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(width: 1, color: Colors.blueAccent),
            ),
          ),
          Container(
            height: 14,
            width: 14,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(width: 3, color: Colors.blueAccent),
            ),
          ),
        ],
      );
    } else {
      return Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(width: 3, color: Colors.blueAccent),
        ),
      );
    }
  }
}
