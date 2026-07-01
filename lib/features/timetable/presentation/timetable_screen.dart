import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/entity/schedule_args.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_args.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_form_args.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _ensureLocationEnabled();

      if (mounted) {
        context.read<TimetableBloc>().add(PageDashboardLoad());
      }
    });
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<TimetableBloc>();
    bloc.add(PageDashboardLoad());
    await bloc.stream.firstWhere(
      (state) => state.status != TimetableStatus.loading,
    );
  }

  Future<void> _ensureLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Akses Lokasi Dibutuhkan'),
            content: const Text(
              'Mohon aktifkan GPS untuk menggunakan fitur ini.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Aktifkan'),
              ),
            ],
          );
        },
      );

      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        context.pop();
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    context.read<TimetableBloc>().add(
      LocationLoaded(lat: position.latitude, long: position.longitude),
    );
  }

  void _showCheckInOutModal(BuildContext screenContext, bool isCheckIn) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title:
              'Apakah ingin melakukan ${isCheckIn ? "Check-In" : "Check-Out"}?',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      isCheckIn
          ? context.read<TimetableBloc>().add(CheckInTimetable())
          : context.read<TimetableBloc>().add(CheckOutTimetable());
    }
  }

  void _showCheckInOutModalToKM(
    BuildContext screenContext,
    bool isCheckin,
    int? idShift,
    int? idKoridorShift,
    int? idBusShift,
    double long,
    double lat,
    bool isCheckIn,
    int? idKm,
    int? idAuditTrail,
  ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan Check-In?',
          desc:
              'Anda akan diminta melakukan foto KM Bus terlebih dahulu untuk ritase pertama kali.',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );
    if (isConfirm == true) {
      final bool? result = isCheckIn
          ? await context.push<bool>(
              '/kmbus/titik-awal/form',
              extra: ScheduleArgs(
                idShift: idShift!,
                idKoridorShift: idKoridorShift!,
                idBusShift: idBusShift!,
                long: long,
                lat: lat,
              ),
            )
          : await context.push<bool>(
              '/kmbus/titik-akhir/form',
              extra: TitikAkhirArgs(idKm: idKm!, idAuditTrail: 0),
            );

      if (result == true) {
        if (isCheckIn) {
          context.read<TimetableBloc>().add(CheckInTimetable());
        } else {
          context.read<TimetableBloc>().add(CheckOutTimetable());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimetableBloc, TimetableState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == TimetableStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: state.message,
            type: SnackbarType.success,
          );

          Future.delayed(const Duration(milliseconds: 200), () {
            context.read<TimetableBloc>().add(PageDashboardLoad());
          });

          if (state.message == "Berhasil check-out!") {
            Future.delayed(const Duration(milliseconds: 200), () {
              context.push(
                '/settlement/form',
                extra: SettlementFormArgs(
                  idAuditTrail: null,
                  idShift: state.idShift,
                  idKoridor: state.idKoridor,
                  idBus: state.idBus,
                  ritaseKe: state.ritaseKe,
                ),
              );
            });
          }
        } else if (state.status == TimetableStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: state.message,
            type: SnackbarType.failed,
          );
        }
      },
      child: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          final isLoading =
              state.status == TimetableStatus.loading ||
              state.status == TimetableStatus.initial ||
              state.status == TimetableStatus.onSubmit;

          return Stack(
            children: [
              Scaffold(
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        CoreHeader(
                          title: "Time Table",
                          customBgColor: Colors.white,
                          withBorder: true,
                        ),
                        const CoreDateTimeWidget(),
                        const SizedBox(height: 10),
                        if (!state.jadwalExist)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              spacing: 15,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.white70,
                                  ),
                                  child: Icon(
                                    Icons.add_alert,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  "Tidak ada jadwal anda pada hari ini.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CoreButton(
                                  onPressed: () {
                                    if (!state.isAllowCheckIn) return;
                                    if (state.checkinData!.ritaseKe != 0.5) {
                                      _showCheckInOutModal(context, true);
                                    } else {
                                      _showCheckInOutModalToKM(
                                        context,
                                        true,
                                        state.checkinData!.idShift,
                                        state.idKoridor,
                                        state.idBus,
                                        state.checkinData!.long,
                                        state.checkinData!.lat,
                                        true,
                                        null,
                                        null,
                                      );
                                    }
                                  },
                                  backgroundColor: state.isAllowCheckIn
                                      ? Colors.green
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.login),
                                        SizedBox(width: 8),
                                        Text("Berangkat"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CoreButton(
                                  onPressed: () {
                                    if (!state.isAllowCheckOut) return;
                                    if (!state.isLastRitase) {
                                      _showCheckInOutModal(context, false);
                                    } else {
                                      _showCheckInOutModalToKM(
                                        context,
                                        true,
                                        state.checkinData!.idShift,
                                        state.idKoridor,
                                        state.idBus,
                                        state.checkinData!.long,
                                        state.checkinData!.lat,
                                        false,
                                        state.idKm,
                                        null,
                                      );
                                    }
                                  },
                                  backgroundColor: state.isAllowCheckOut
                                      ? Colors.red
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.logout),
                                        SizedBox(width: 8),
                                        Text("Datang"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Riwayat Terakhir',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await context.push('/timetable/history');

                                  if (context.mounted) {
                                    context.read<TimetableBloc>().add(
                                      PageDashboardLoad(),
                                    );
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.listTimetable.isEmpty)
                          Center(child: const Text("Belum ada data tersimpan."))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.listTimetable.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final data = state.listTimetable[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data.tanggal,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            "${data.platNomor} (${data.nomorLambung})",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        spacing: 15,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Berangkat",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .greenAccent
                                                        .shade100,
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.green,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    spacing: 5,
                                                    children: [
                                                      Icon(
                                                        Icons.timer_outlined,
                                                        size: 20,
                                                      ),
                                                      Text(
                                                        data.jamBerangkat != ''
                                                            ? StringFormatter()
                                                                  .formatLongTimeToMedium(
                                                                    data.jamBerangkat,
                                                                  )
                                                            : '--:--:--',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Datang",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .redAccent
                                                        .shade100,
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.red,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    spacing: 5,
                                                    children: [
                                                      Icon(
                                                        Icons.timer_outlined,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        data.jamDatang != ''
                                                            ? StringFormatter()
                                                                  .formatLongTimeToMedium(
                                                                    data.jamDatang,
                                                                  )
                                                            : '--:--:--',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data.namaKoridor,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            child: Text(
                                              data.ritaseKe.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(120),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
