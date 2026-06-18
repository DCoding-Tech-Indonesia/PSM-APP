import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_state.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/leave_request_list_card.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/leave_request_form_sheet.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portalState = context.read<PortalBloc>().state;
    String role = '';
    if (portalState is PortalLoaded) {
      role = portalState.profile.role;
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: role.toLowerCase().contains('pegawai')
                  ? 'Pengajuan Cuti'
                  : 'Verifikasi Cuti',
              subtitle: role.toLowerCase().contains('pegawai')
                  ? 'Silahkan ajukan cuti anda'
                  : 'Silahkan verifikasi cuti anda',
              showBackButton: true,
              onBackPressed: () => context.pop(),
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
                        final portalState = context.read<PortalBloc>().state;
                        String userId = '';
                        if (portalState is PortalLoaded) {
                          userId = portalState.profile.id;
                        }

                        final bloc = context.read<LeaveRequestBloc>();
                        bloc.add(
                          LoadLeaveRequestList(userId: int.tryParse(userId)!),
                        );
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
                                  child: _LeaveRequestEmptyState(role: role),
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
      floatingActionButton: role.toLowerCase().contains('pegawai')
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
  const _LeaveRequestEmptyState({required this.role});
  final String role;

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
              role.toLowerCase().contains('pegawai')
                  ? 'Belum Ada Pengajuan Cuti'
                  : 'Belum Ada Verifikasi Cuti',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role.toLowerCase().contains('pegawai')
                  ? 'Daftar pengajuan cuti Anda akan muncul di sini.'
                  : 'Daftar verifikasi cuti akan muncul di sini.',
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
