import 'package:flutter/material.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';

class SettlementHeader extends StatelessWidget {
  const SettlementHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreHeader(title: 'Settlement', subtitle: 'Rekapitulasi Tugas');
  }
}
