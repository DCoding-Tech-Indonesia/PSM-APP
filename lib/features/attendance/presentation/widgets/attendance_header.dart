import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';

class AttendanceHeader extends StatelessWidget {
  const AttendanceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreHeader(
      title: 'Absensi',
      subtitle: 'Check-in & Check-out',
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.checklist),
      //     onPressed: () {
      //       context.push('/approval');
      //     },
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.refresh),
      //     onPressed: () {
      //       context.read<AttendanceBloc>().add(RefreshLocation());
      //     },
      //   ),
      // ],
    );
  }
}
