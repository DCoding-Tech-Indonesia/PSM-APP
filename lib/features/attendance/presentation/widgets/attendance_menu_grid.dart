import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';
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
    final theme = Theme.of(context);

    final size = MediaQuery.of(context).size;
    final itemWidth = (size.width - 32 - 8 * 3) / 4; // 32 margin + 3*8 spacing
    final itemHeight = itemWidth * 0.9; // Sesuaikan dengan childAspectRatio

    final List<_MenuItem> items = [
      _MenuItem(
        title: 'Approval',
        icon: Icons.check_circle_outlined,
        color: theme.primaryColor,
        route: '/approval',
        onTap: null,
      ),
      _MenuItem(
        title: 'Pergantian Jadwal',
        icon: Icons.swap_horiz_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: () {
          int replacementId = 0;
          int jadwalId = 0;
          String reason = '';
          bool isLoadingPengganti = false;
          List<dynamic> listPengganti = [];

          // Ambil repo dari outer context SEBELUM dialog dibuka
          // karena context di dalam StatefulBuilder (dialog) tidak punya akses ke provider
          showCoreConfirmDialog(
            context: context,
            title: 'Ganti Jadwal',
            message: 'Anda yakin ingin mengganti jadwal?',
            contentWidget: StatefulBuilder(
              builder: (dialogContext, setState) {
                return Column(
                  children: [
                    CoreDropdownSearch<ScheduleModel>(
                      label: 'Jadwal',
                      hintText: 'Pilih jadwal',
                      popupTitle: 'Pilih Jadwal',
                      isRequired: true,
                      isItemSelected: (s) => s.id == jadwalId,
                      items: state.schedules,
                      itemAsString: (s) =>
                          '${s.tanggal} - ${s.shift.name} - ${s.lokasi.namaLokasi}',
                      compareFn: (a, b) => a.id == b.id,
                      onSelected: (selected) async {
                        if (selected != null) {
                          final selectedId =
                              int.tryParse(selected.id.toString()) ?? 0;

                          setState(() {
                            jadwalId = selectedId;
                            isLoadingPengganti = true;
                            listPengganti = [];
                          });

                          try {
                            final result = await onFetchReplacementSchedules(
                              selectedId,
                            );
                            setState(() {
                              listPengganti = result;
                              isLoadingPengganti = false;
                            });
                          } catch (e) {
                            setState(() {
                              isLoadingPengganti = false;
                            });
                          }
                        }
                      },
                    ),
                    if (jadwalId > 0) ...[
                      const SizedBox(height: 16),
                      if (isLoadingPengganti)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Column(
                          children: [
                            CoreDropdownSearch<dynamic>(
                              label: 'Pengganti',
                              hintText: 'Pilih pengganti',
                              popupTitle: 'Pilih Pengganti',
                              items: listPengganti,
                              itemAsString: (s) =>
                                  '${s['fullName']?.toString()} - ${s['shiftName']?.toString()} - ${s['tanggal']?.toString()}',
                              compareFn: (a, b) => a['userId'] == b['userId'],
                              onSelected: (selected) {
                                if (selected != null) {
                                  setState(() {
                                    replacementId =
                                        int.tryParse(
                                          selected['userId'].toString(),
                                        ) ??
                                        0;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CoreInputFieldNew(
                              label: 'Alasan',
                              hintText: 'Alasan',
                              onChanged: (v) {
                                reason = v;
                              },
                            ),
                          ],
                        ),
                    ],
                  ],
                );
              },
            ),
            onConfirm: () async {
              if (jadwalId == 0 || replacementId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih jadwal dan pengganti!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final success = await onRequestShiftReplacement(
                  requesterId: int.tryParse(state.userId) ?? 0,
                  replacementId: replacementId,
                  jadwalId: jadwalId,
                  alasan: reason,
                );

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil mengajukan ganti jadwal!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        },
      ),
      _MenuItem(
        title: 'Pengajuan Cuti',
        icon: Icons.event_note_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: null,
      ),
      _MenuItem(
        title: 'Jadwal',
        icon: Icons.calendar_month_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: () {
          context.push('/schedule-calendar', extra: state.schedulePerMonth);
        },
      ),
      _MenuItem(
        title: 'History',
        icon: Icons.history_outlined,
        color: theme.primaryColor,
        route: null,
        onTap: null,
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
