import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';

class ApprovalHeader extends StatelessWidget {
  const ApprovalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CoreHeader(
      title: 'Approval',
      subtitle: 'Approval Pergantian Jadwal Kerja',
      onBackPressed: () => context.pop(),
    );
  }
}
