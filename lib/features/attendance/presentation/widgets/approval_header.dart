import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';
// import 'package:travis/features/attendance/presentation/bloc/approval_bloc.dart';
// import 'package:travis/features/attendance/presentation/bloc/approval_state.dart';

class ApprovalHeader extends StatelessWidget {
  const ApprovalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreHeader(
      title: 'Approval',
      subtitle: 'Approval Pergantian Jadwal Kerja',
      onBackPressed: () => context.pop(),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.refresh),
      //     onPressed: () {
      //       context.read<ApprovalBloc>().add(LoadApprovalData());
      //     },
      //   ),
      // ],
    );
  }
}
