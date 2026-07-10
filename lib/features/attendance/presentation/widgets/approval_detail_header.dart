import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';

class ApprovalDetailHeader extends StatelessWidget {
  final int approvalId;

  const ApprovalDetailHeader({super.key, required this.approvalId});

  @override
  Widget build(BuildContext context) {
    return CoreHeader(
      title: 'Detail Approval',
      subtitle: 'Permohonan Pergantian Jadwal Kerja',
      onBackPressed: () => context.pop(),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.refresh),
      //     onPressed: () {
      //       context.read<ApprovalBloc>().add(
      //         LoadApprovalDetail(id: approvalId),
      //       );
      //     },
      //   ),
      // ],
    );
  }
}
