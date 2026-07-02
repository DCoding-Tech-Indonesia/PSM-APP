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
    String typePegawai = '';
    if (portalState is PortalLoaded) {
      role = portalState.profile.role;
      typePegawai = portalState.profile.typePegawaiCode;
    }
    final theme = Theme.of(context);

    final List<_MenuItem> items = [
      if (role.toLowerCase().contains('korlap') ||
          typePegawai.toLowerCase().contains('pgw_mngr_opr'))
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
      if (typePegawai.toLowerCase().contains('pgw_mngr_opr'))
        _MenuItem(
          title: 'Verifikasi Cuti',
          icon: Icons.check_circle_outline,
          color: theme.primaryColor,
          route: '/leave-approval',
          onTap: null,
        ),
      if (role.toLowerCase().contains('pegawai') ||
          role.toLowerCase().contains('manager_operational'))
        _MenuItem(
          title: 'Pengajuan Cuti',
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
          context.push(
            '/history',
            extra: {'history': state.history, 'userId': state.userId},
          );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              // 4 items horizontal: 4 columns, 3 gaps of 8.0 spacing
              final itemWidth = (availableWidth - 8.0 * 3) / 4;

              // Scale factor based on standard 360 width screen where itemWidth is ~76
              final double scale = (itemWidth / 76.0).clamp(0.8, 1.2);
              final double iconSize = (28.0 * scale).clamp(20.0, 28.0);
              final double containerPadding = (12.0 * scale).clamp(8.0, 12.0);
              final double fontSize = (11.0 * scale).clamp(9.5, 11.5);
              final double verticalPadding = (8.0 * scale).clamp(4.0, 8.0);

              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: items.map((item) {
                  return SizedBox(
                    width: itemWidth,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.0,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(containerPadding),
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
                                          color: item.color.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: item.color.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: item.color,
                                        size: iconSize,
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
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
