import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/helper/string_formatter.dart';
import 'package:travis/core/presentations/entity/schedule_args.dart';
import 'package:travis/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:travis/core/presentations/widgets/core_date_time_widget.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';
import 'package:travis/core/router/route_observer.dart';
import 'package:travis/features/kmbus/domain/entities/titik_akhir_args.dart';
import 'package:travis/features/settlement/domain/entities/settlement_form_args.dart';
import 'package:travis/features/timetable/domain/entities/timetable_data.dart';
import 'package:travis/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:travis/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:travis/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with RouteAware {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      context.read<TimetableBloc>().add(PageDashboardLoad());
    }
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

  void _showCheckInConfirmation(BuildContext screenContext) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan Check-In?',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<TimetableBloc>().add(CheckInTimetable());
    }
  }

  void _showCheckOutConfirmation(
    BuildContext screenContext,
    isLastRitase,
    int? idShift,
    int? idKoridorShift,
    int? idBusShift,
    double long,
    double lat,
    int? idKm,
    int? idAuditTrail,
  ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan Check-Out?',
          desc: isLastRitase
              ? 'Anda akan diminta melakukan foto KM Bus setelah melakukan Check-Out.'
              : '',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );
    if (isConfirm == true) {
      context.read<TimetableBloc>().add(CheckOutTimetable());
    }
  }

  void _showSettlementConfirmation(
    BuildContext screenContext,
    int? idShift,
    int? idKoridorShift,
    int? idBusShift,
    double? ritaseKe,
  ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Check-Out Berhasil',
          desc: 'Apakah ingin langsung melakukan input settlement?',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );
    if (isConfirm == true) {
      context.push(
        '/settlement/form',
        extra: SettlementFormArgs(
          idAuditTrail: null,
          idShift: idShift,
          idKoridor: idKoridorShift,
          idBus: idBusShift,
          ritaseKe: ritaseKe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimetableBloc, TimetableState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == TimetableStatus.successSave ||
            state.status == TimetableStatus.successCheckIn ||
            state.status == TimetableStatus.successCheckOut) {
          CoreSnackbar.show(
            context,
            message: state.message,
            type: SnackbarType.success,
          );

          Future.delayed(const Duration(milliseconds: 200), () {
            context.read<TimetableBloc>().add(PageDashboardLoad());
          });

          if (state.status == TimetableStatus.successCheckIn &&
              state.ritaseKe == 0.5) {
            context.push<bool>(
              '/kmbus/titik-awal/form',
              extra: ScheduleArgs(
                idShift: state.idShift!,
                idKoridorShift: state.idKoridor,
                idBusShift: state.idBus,
              ),
            );
          }

          if (state.status == TimetableStatus.successCheckOut) {
            Future.microtask(() async {
              if (!context.mounted) return;

              if (state.isLastRitase && (state.idKm ?? 0) > 0) {
                final titikAkhirResult = await context.push<bool>(
                  '/kmbus/titik-akhir/form',
                  extra: TitikAkhirArgs(
                    idKm: state.idKm ?? 0,
                    idAuditTrail: 0,
                  ),
                );
                if (titikAkhirResult == true && context.mounted) {
                  _showSettlementConfirmation(
                    context,
                    state.checkinData!.idShift,
                    state.idKoridor,
                    state.idBus,
                    state.ritaseKe,
                  );
                }
                return;
              }

              _showSettlementConfirmation(
                context,
                state.checkinData!.idShift,
                state.idKoridor,
                state.idBus,
                state.ritaseKe,
              );
            });
          }
        } else if (state.status == TimetableStatus.failedSave) {
          if (state.message.trim().toLowerCase().contains(
            "titik akhir belum dibuat",
          )) {
            CoreSnackbar.show(
              context,
              message: "Harap isi Titik Akhir KM Bus terlebih dahulu.",
              type: SnackbarType.warning,
            );

            Future.delayed(const Duration(milliseconds: 500), () async {
              if (!context.mounted) return;
              final bool? result = await context.push<bool>(
                '/kmbus/titik-akhir/form',
                extra: TitikAkhirArgs(idKm: state.idKm ?? 0, idAuditTrail: 0),
              );

              if (result == true) {
                if (context.mounted) {
                  context.read<TimetableBloc>().add(CheckOutTimetable());
                }
              }
            });
          } else {
            CoreSnackbar.show(
              context,
              message: state.message,
              type: SnackbarType.failed,
            );
          }
        }
      },
      child: BlocBuilder<TimetableBloc, TimetableState>(
        builder: (context, state) {
          final isInitialLoading =
              (state.status == TimetableStatus.loading ||
                  state.status == TimetableStatus.initial) &&
              (state.listTimetable.isEmpty ?? true);
          final isLoading = state.status == TimetableStatus.onSubmit;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: const Color(0xFFF5F7FA),
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF1565C0),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const CoreHeader(
                          title: "Time Table",
                          subtitle: "Jadwal kamu hari ini",
                        ),
                        CoreDateTimeWidget(
                          noUnit: state.jadwalExist && state.noUnit.isNotEmpty 
                              ? state.noUnit 
                              : null,
                          namaKoridor: state.jadwalExist && state.namaKoridor.isNotEmpty 
                              ? state.namaKoridor 
                              : null,
                          ritaseKe: state.checkinData?.ritaseKe,
                          isLastRitase: state.isLastRitase,
                          showScheduleInfo: state.jadwalExist && state.noUnit.isNotEmpty,
                          isAllowCheckIn: state.isAllowCheckIn,
                          isAllowCheckOut: state.isAllowCheckOut,
                          isNextRitase: state.isNextRitase,
                        ),
                        const SizedBox(height: 4),
                        if (isInitialLoading)
                          ..._buildSkeletonItems()
                        else ...[
                          // === NO SCHEDULE WARNING ===
                          if (!state.jadwalExist)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE53935),
                                    Color(0xFFEF5350),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE53935,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.event_busy_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Tidak Ada Jadwal",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Anda tidak memiliki jadwal pada hari ini.",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (!state.jadwalExist) const SizedBox(height: 8),

                          // === ACTION BUTTONS ===
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.login_rounded,
                                    label: 'Berangkat',
                                    isEnabled: state.isAllowCheckIn && state.status != TimetableStatus.onSubmit,
                                    enabledColors: const [
                                      Color(0xFF2E7D32),
                                      Color(0xFF43A047),
                                    ],
                                    onPressed: () {
                                      if (!state.isAllowCheckIn) {
                                        CoreSnackbar.show(
                                          context,
                                          message:
                                              state.disabledBerangkatMessage!,
                                          type: SnackbarType.warning,
                                        );
                                        return;
                                      }
                                      _showCheckInConfirmation(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.logout_rounded,
                                    label: 'Datang',
                                    isEnabled: state.isAllowCheckOut && state.status != TimetableStatus.onSubmit,
                                    enabledColors: const [
                                      Color(0xFFC62828),
                                      Color(0xFFE53935),
                                    ],
                                    onPressed: () {
                                      if (!state.isAllowCheckOut) {
                                        CoreSnackbar.show(
                                          context,
                                          message: state.disabledDatangMessage!,
                                          type: SnackbarType.warning,
                                        );

                                        return;
                                      }
                                      _showCheckOutConfirmation(
                                        context,
                                        state.isLastRitase,
                                        state.checkinData!.idShift,
                                        state.idKoridor,
                                        state.idBus,
                                        state.checkinData!.long,
                                        state.checkinData!.lat,
                                        state.idKm,
                                        null,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // === HISTORY HEADER ===
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
                                    'Riwayat Perjalanan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await context.push('/timetable/history');

                                    if (context.mounted) {
                                      context.read<TimetableBloc>().add(
                                        PageDashboardLoad(),
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue[700],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Lihat Semua',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios, size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // === HISTORY LIST / EMPTY STATE ===
                          if (state.listTimetable.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Belum ada riwayat perjalanan",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.listTimetable.length,
                              itemBuilder: (context, index) {
                                final data = state.listTimetable[index];
                                return _buildHistoryCard(data);
                              },
                            ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // === LOADING OVERLAY ===
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1565C0),
                              ),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            // Text(
                            //   'Memuat data...',
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w500,
                            //     color: Color(0xFF616161),
                            //   ),
                            // ),
                          ],
                        ),
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

  // === HELPER WIDGETS ===

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isEnabled,
    required List<Color> enabledColors,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: enabledColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isEnabled ? null : const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: enabledColors.first.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TimetableData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Calendar Icon + Date | Bus Unit Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.tanggal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    "${data.platNomor} • ${data.nomorLambung}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A5568),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEDF2F7),
              ),
            ),

            // Timeline Route
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator line
                  Column(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF2E7D32),
                      ),
                      Container(
                        width: 1.5,
                        height: 28,
                        color: const Color(0xFFE2E8F0),
                      ),
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFFC62828),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Time Info Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Berangkat (Check-In)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              data.jamBerangkat.trim().isEmpty
                                  ? "--:--:--"
                                  : StringFormatter()
                                        .formatLongTimeToMedium(
                                          data.jamBerangkat,
                                        ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color:
                                    data.jamBerangkat.trim().isEmpty
                                    ? const Color(0xFFA0AEC0)
                                    : const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Datang (Check-Out)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              data.jamDatang.trim().isEmpty
                                  ? "--:--:--"
                                  : StringFormatter()
                                        .formatLongTimeToMedium(
                                          data.jamDatang,
                                        ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: data.jamDatang.trim().isEmpty
                                    ? const Color(0xFFA0AEC0)
                                    : const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEDF2F7),
              ),
            ),

            // Footer: Corridor + Ritase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_bus_rounded,
                        size: 15,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.namaKoridor,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(
                        0xFF1565C0,
                      ).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    "Ritase ${data.ritaseKe.toString().replaceAll('.0', '')}",
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkeletonItems() {
    return [
      // Action Buttons Skeleton
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: CoreSkeletonWidget(
                width: double.infinity,
                height: 50,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CoreSkeletonWidget(
                width: double.infinity,
                height: 50,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      // History Header Skeleton
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CoreSkeletonWidget(width: 150, height: 18),
            CoreSkeletonWidget(
              width: 80,
              height: 24,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
      const SizedBox(height: 4),
      // History Cards Skeleton
      ...List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CoreSkeletonWidget(width: 100, height: 14),
                              const Spacer(),
                              CoreSkeletonWidget(
                                width: 60,
                                height: 20,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const CoreSkeletonWidget(width: 150, height: 16),
                              const Spacer(),
                              CoreSkeletonWidget(
                                width: 40,
                                height: 20,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const CoreSkeletonWidget(width: 200, height: 14),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CoreSkeletonWidget(
                                        width: 16,
                                        height: 16,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            CoreSkeletonWidget(
                                              width: 50,
                                              height: 10,
                                            ),
                                            SizedBox(height: 4),
                                            CoreSkeletonWidget(
                                              width: 40,
                                              height: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      CoreSkeletonWidget(
                                        width: 16,
                                        height: 16,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            CoreSkeletonWidget(
                                              width: 50,
                                              height: 10,
                                            ),
                                            SizedBox(height: 4),
                                            CoreSkeletonWidget(
                                              width: 40,
                                              height: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 20),
    ];
  }
}
