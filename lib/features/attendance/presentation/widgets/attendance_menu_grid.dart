import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';
import 'package:psm_mobile/features/portal/presentation/widget/portal_dialogs.dart';

class AttendanceMenuGrid extends StatelessWidget {
  final AttendanceLoaded state;
  final Future<List<dynamic>> Function(int jadwalId)
  onFetchReplacementSchedules;
  final Future<bool> Function({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  })
  onRequestShiftReplacement;

  const AttendanceMenuGrid({
    super.key,
    required this.state,
    required this.onFetchReplacementSchedules,
    required this.onRequestShiftReplacement,
  });

  @override
  Widget build(BuildContext context) {
    final portalState = context.read<PortalBloc>().state;
    String role = '';
    if (portalState is PortalLoaded) {
      role = portalState.profile.role;
    }
    final theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final itemWidth = (size.width - 32 - 8 * 3) / 4; // 32 margin + 3*8 spacing
    final itemHeight = itemWidth * 0.9; // Sesuaikan dengan childAspectRatio

    final List<_MenuItem> items = [
      if (role.toLowerCase().contains('korlap'))
        _MenuItem(
          title: 'Approval Jadwal',
          icon: Icons.check_circle_outlined,
          color: theme.primaryColor,
          route: '/approval',
          onTap: null,
        ),
      if (role.toLowerCase().contains('korlap') ||
          role.toLowerCase().contains('prmg'))
        _MenuItem(
          title: 'Pergantian Jadwal',
          icon: Icons.swap_horiz_outlined,
          color: theme.primaryColor,
          route: null,
          onTap: () {
            context.push(
              '/shift-replacement',
              extra: {
                'schedules': state.schedules,
                'requesterId': int.tryParse(state.userId) ?? 0,
                'onFetchReplacementSchedules': onFetchReplacementSchedules,
                'onRequestShiftReplacement': onRequestShiftReplacement,
              },
            );
          },
        ),
      if (role.toLowerCase().contains('pegawai'))
        _MenuItem(
          title: role.toLowerCase().contains('pegawai')
              ? 'Pengajuan Cuti'
              : 'Verifikasi Cuti',
          icon: Icons.event_note_outlined,
          color: theme.primaryColor,
          route: '/leave-request',
          onTap: null,
        ),
      _MenuItem(
        title: 'Jadwal',
        icon: Icons.calendar_month_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: () {
          context.push('/schedule-calendar', extra: state.userId);
        },
      ),
      _MenuItem(
        title: 'History',
        icon: Icons.history_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: () {
          context.push('/history', extra: {
            'history': state.history,
            'userId': state.userId,
          });
        },
      ),
      _MenuItem(
        title: 'Lainnya',
        icon: Icons.more_horiz_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: null,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.01),
              width: 1,
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing:
                  itemWidth * 0.1, // Sesuaikan dengan childAspectRatio
              crossAxisSpacing:
                  itemWidth * 0.1, // Sesuaikan dengan childAspectRatio
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // if (kDebugMode) {
                        //   print('Tapped on ${item.title}');
                        // }
                        if (item.route == null && item.onTap == null) {
                          if (kDebugMode) {
                            print('No action defined for ${item.title}');
                          }
                          PortalDialogs.showComingSoonDialog(
                            context,
                            item.title,
                            "Fitur ini masih dalam pengembangan.",
                          );
                          return;
                        }
                        if (item.route != null) {
                          context.push(item.route!);
                        } else if (item.onTap != null) {
                          item.onTap!();
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      item.color.withValues(alpha: 0.05),
                                      item.color.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: item.color.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: item.color.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.color.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  final VoidCallback? onTap;

  _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.route,
    this.onTap,
  });
}
