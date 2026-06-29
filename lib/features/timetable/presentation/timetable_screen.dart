import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
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

  Future<void> _showCheckoutConfirmation(BuildContext context) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: "Konfirmasi Check-out",
          desc:
          "Pastikan perjalanan telah selesai dan Anda yakin ingin melakukan check-out.",
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true && context.mounted) {
      context.read<TimetableBloc>().add(CheckOutTimetable());
    }
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

  void _handleCheckInSubmit(BuildContext ctx, TimetableState state) {
    if (state.checkinData != null && state.checkinData!.isSubmittable) {
      Navigator.pop(ctx);

      context.read<TimetableBloc>().add(CheckInTimetable());
    } else {
      final errorMsg =
          state.checkinData?.validationErrorMessage ??
          "Data formulir belum lengkap.";

      CoreSnackbar.show(context, message: errorMsg, type: SnackbarType.warning);
    }
  }

  void _showCheckInOutModal(BuildContext screenContext, bool isCheckin) {
    showDialog(
      context: screenContext,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: screenContext.read<TimetableBloc>(),
          child: Dialog(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.blueAccent, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Icon(
                                isCheckin ? Icons.login : Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                isCheckin ? "Check-in" : "Check-out",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(screenContext),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          BlocBuilder<TimetableBloc, TimetableState>(
                            buildWhen: (prev, curr) =>
                                prev.checkinData?.ritaseKe !=
                                curr.checkinData?.ritaseKe,
                            builder: (context, state) {
                              final ritaseValue = state.checkinData?.ritaseKe;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Ritase Berikutnya",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withAlpha(100),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.green,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        ritaseValue != null && ritaseValue != 0
                                            ? ritaseValue.toString()
                                            : "RIT",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          BlocBuilder<TimetableBloc, TimetableState>(
                            buildWhen: (prev, curr) =>
                                prev.idKoridor != curr.idKoridor ||
                                prev.referenceKoridor != curr.referenceKoridor,
                            builder: (context, state) {
                              ReferenceDetail? selectedKoridor;

                              if (state.referenceKoridor.isNotEmpty) {
                                final matched = state.referenceKoridor.where(
                                  (e) => e.id == state.idKoridor,
                                );
                                if (matched.isNotEmpty) {
                                  selectedKoridor = matched.first;
                                }
                              }

                              return CoreDropdownSearch<ReferenceDetail>(
                                readOnly: true,
                                label: 'Pilih Koridor',
                                hintText: 'Pilih Koridor',
                                popupTitle: 'Daftar Koridor',
                                items: state.referenceKoridor,
                                selectedItem: selectedKoridor,
                                itemAsString: (item) =>
                                    '${item.code} - ${item.name}',
                                compareFn: (a, b) => a.id == b.id,
                                isRequired: true,
                                isItemSelected: (item) =>
                                    item.id == state.idKoridor,
                                onSelected: (value) {
                                  if (value == null) return;
                                  context.read<TimetableBloc>().add(
                                    SelectKoridor(value.id, value.name),
                                  );
                                },
                              );
                            },
                          ),

                          BlocBuilder<TimetableBloc, TimetableState>(
                            builder: (context, state) {
                              if (state.idKoridor == 0) {
                                return const SizedBox.shrink();
                              }

                              if (state.status == TimetableStatus.fetching) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (state.referenceBus.isEmpty &&
                                  state.idKoridor != 0) {
                                return const Text(
                                  "Tidak terdapat bus terdata di koridor tersebut",
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }

                              ReferenceDetail? selectedBus;
                              if (state.referenceBus.isNotEmpty) {
                                final matched = state.referenceBus.where(
                                  (e) => e.id == state.idBus,
                                );
                                if (matched.isNotEmpty)
                                  selectedBus = matched.first;
                              }

                              return CoreDropdownSearch<ReferenceDetail>(
                                readOnly: true,
                                label: 'Pilih Bus',
                                hintText: 'Pilih Bus',
                                popupTitle: 'Daftar Bus',
                                items: state.referenceBus,
                                selectedItem: selectedBus,
                                itemAsString: (item) =>
                                    '${item.code} - ${item.name}',
                                compareFn: (a, b) => a.id == b.id,
                                isItemSelected: (item) =>
                                    item.id == state.idBus,
                                isRequired: true,
                                onSelected: (value) {
                                  if (value == null) return;
                                  context.read<TimetableBloc>().add(
                                    SelectBus(value.id, value.name),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          BlocBuilder<TimetableBloc, TimetableState>(
                            buildWhen: (prev, curr) =>
                                prev.checkinData != curr.checkinData,
                            builder: (context, state) {
                              final isFormValid =
                                  state.checkinData?.isSubmittable ?? false;

                              return CoreButton(
                                width: double.infinity,
                                onPressed: () =>
                                    _handleCheckInSubmit(context, state),
                                backgroundColor: isFormValid
                                    ? Colors.green
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                child: const Text("Submit"),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (screenContext.mounted) {
        screenContext.read<TimetableBloc>().add(ResetInput());
      }
    });
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
                                    _showCheckInOutModal(context, true);
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
                                        Text("Check-in"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CoreButton(
                                  onPressed: () {
                                    if (!state.isAllowCheckOut) return;
                                    _showCheckoutConfirmation(context);
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
                                        Text("Check-out"),
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
                                                  "Check-In",
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
                                                  "Check-Out",
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
