import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/notification/approval_refresh_notifier.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';
import 'package:travis/features/attendance/presentation/bloc/leave_request_bloc.dart';
import 'package:travis/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:travis/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:travis/features/attendance/presentation/bloc/leave_request_state.dart';
import 'package:travis/features/attendance/presentation/widgets/leave_request_list_card.dart';
import 'package:travis/features/attendance/presentation/widgets/leave_request_form_sheet.dart';
import 'package:travis/features/portal/presentation/bloc/portal_state.dart';

class LeaveRequestScreen extends StatefulWidget {
  final String title;
  final bool isApproval;
  final int sisaCuti;

  const LeaveRequestScreen({
    super.key,
    this.title = 'Pengajuan Cuti',
    this.isApproval = false,
    this.sisaCuti = 0,
  });

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  StreamSubscription<void>? _refreshSub;

  @override
  void initState() {
    super.initState();
    _refreshSub = ApprovalRefreshNotifier.instance.stream.listen((_) {
      _refreshList();
    });
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    super.dispose();
  }

  void _refreshList() {
    int? userId;
    if (!widget.isApproval) {
      final portalState = context.read<PortalBloc>().state;
      if (portalState is PortalLoaded) {
        userId = int.tryParse(portalState.profile.id);
      }
    }
    context.read<LeaveRequestBloc>().add(LoadLeaveRequestList(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: widget.title,
              subtitle: widget.isApproval
                  ? 'Silahkan verifikasi cuti anda'
                  : 'Silahkan ajukan cuti anda',
              showBackButton: true,
              onBackPressed: () => context.pop(),
            ),
            if (!widget.isApproval)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available, color: theme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sisa Jatah Cuti Anda',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.sisaCuti} Hari',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
                builder: (context, state) {
                  if (state is LeaveRequestInitial ||
                      (state is LeaveRequestLoaded &&
                          state.isLoading &&
                          state.leaveRequests.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LeaveRequestError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is LeaveRequestLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        int? userId;
                        if (!widget.isApproval) {
                          final portalState = context.read<PortalBloc>().state;
                          if (portalState is PortalLoaded) {
                            userId = int.tryParse(portalState.profile.id);
                          }
                        }

                        final bloc = context.read<LeaveRequestBloc>();
                        bloc.add(LoadLeaveRequestList(userId: userId));
                        await bloc.stream.firstWhere(
                          (s) => s is LeaveRequestLoaded && !s.isLoading,
                        );
                      },
                      child: state.leaveRequests.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: _LeaveRequestEmptyState(
                                    isApproval: widget.isApproval,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                top: 8,
                              ),
                              itemCount: state.leaveRequests.length,
                              itemBuilder: (context, index) {
                                return LeaveRequestListCard(
                                  leaveRequest: state.leaveRequests[index],
                                );
                              },
                            ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !widget.isApproval
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) {
                    return BlocProvider.value(
                      value: context.read<LeaveRequestBloc>(),
                      child: const LeaveRequestFormSheet(),
                    );
                  },
                );
              },
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _LeaveRequestEmptyState extends StatelessWidget {
  const _LeaveRequestEmptyState({required this.isApproval});
  final bool isApproval;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_outlined,
                size: 56,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isApproval
                  ? 'Belum Ada Verifikasi Cuti'
                  : 'Belum Ada Pengajuan Cuti',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isApproval
                  ? 'Daftar verifikasi cuti akan muncul di sini.'
                  : 'Daftar pengajuan cuti Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
