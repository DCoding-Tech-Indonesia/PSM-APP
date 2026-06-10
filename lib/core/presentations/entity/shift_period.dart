import 'package:flutter/material.dart';

class ShiftPeriod {
  final TimeOfDay start;
  final TimeOfDay end;

  const ShiftPeriod({
    required this.start,
    required this.end,
  });
}