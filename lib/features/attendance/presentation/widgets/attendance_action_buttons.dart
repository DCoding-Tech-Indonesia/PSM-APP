import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';

class AttendanceActionButtons extends StatelessWidget {
  final AttendanceLoaded state;

  const AttendanceActionButtons({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      child: Row(
        children: [
          Expanded(
            child: CoreButton(
              height: 56,
              backgroundColor: state.isCheckedIn ? Colors.grey : Colors.green,
              foregroundColor: Colors.white,
              onPressed: (state.isLoading || state.radiusInfo == '0m')
                  ? null
                  : state.isCheckedIn
                  ? null
                  : () {
                      if (state.isMocked) {
                        showCoreErrorDialog(
                          context,
                          'Fake GPS Terdeteksi',
                          'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.',
                        );
                      } else if (!state.canCheckIn) {
                        showCoreErrorDialog(
                          context,
                          'Di Luar Lokasi',
                          'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.',
                        );
                      } else {
                        // int selectedBusId = 0;

                        showCoreConfirmDialog(
                          context: context,
                          title: 'Konfirmasi Check-in',
                          message:
                              'Apakah Anda yakin ingin melakukan Check-in sekarang?',
                          color: Colors.green,
                          onConfirm: () => context.read<AttendanceBloc>().add(
                            CheckInRequested(),
                          ),
                          // contentWidget: StatefulBuilder(
                          //   builder: (context, setState) {
                          //     return Column(
                          //       children: [
                          //         CoreDropdownSearch<dynamic>(
                          //           label: 'Bus',
                          //           hintText: 'Pilih bus',
                          //           popupTitle: 'Pilih Bus',
                          //           items: state.bus,
                          //           itemAsString: (s) =>
                          //               'No. Lambung ${s['code']} - ${s['name']?.toString()}',
                          //           compareFn: (a, b) => a['id'] == b['id'],
                          //           onSelected: (selected) {
                          //             if (selected != null) {
                          //               selectedBusId =
                          //                   int.tryParse(
                          //                     selected['id'].toString(),
                          //                   ) ??
                          //                   0;
                          //             }
                          //           },
                          //         ),
                          //       ],
                          //     );
                          //   },
                          // ),
                        );
                      }
                    },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(state.isCheckedIn ? Icons.check_circle : Icons.login),
                    const SizedBox(width: 8),
                    Text(
                      state.isCheckedIn ? 'Check-in' : 'Check-in',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CoreButton(
              height: 56,
              backgroundColor: state.checkOutTime.isNotEmpty
                  ? Colors.grey
                  : Colors.red,
              foregroundColor: Colors.white,
              onPressed: (state.isLoading || state.radiusInfo == '0m')
                  ? null
                  : (state.checkOutTime.isNotEmpty || !state.isCheckedIn)
                  ? null
                  : () {
                      if (state.isMocked) {
                        showCoreErrorDialog(
                          context,
                          'Fake GPS Terdeteksi',
                          'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.',
                        );
                      } else if (!state.canCheckIn) {
                        showCoreErrorDialog(
                          context,
                          'Di Luar Lokasi',
                          'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.',
                        );
                      } else {
                        showCoreConfirmDialog(
                          context: context,
                          title: 'Konfirmasi Check-out',
                          message:
                              'Apakah Anda yakin ingin melakukan Check-out sekarang?',
                          color: Colors.red,
                          onConfirm: () => context.read<AttendanceBloc>().add(
                            CheckOutRequested(),
                          ),
                        );
                      }
                    },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.checkOutTime.isNotEmpty
                          ? Icons.check_circle
                          : Icons.logout,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.checkOutTime.isNotEmpty ? 'Check-out' : 'Check-out',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
