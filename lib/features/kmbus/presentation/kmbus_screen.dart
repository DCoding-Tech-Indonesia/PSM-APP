import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/entity/schedule_args.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';

import 'bloc/kmbus_bloc.dart';
import 'bloc/kmbus_event.dart';

class KmbusScreen extends StatefulWidget {
  const KmbusScreen({super.key});

  @override
  State<KmbusScreen> createState() => _KmbusScreenState();
}

class _KmbusScreenState extends State<KmbusScreen> {
  @override
  void initState() {
    super.initState();

    // Langsung tembak load dashboard tanpa cek GPS
    Future.microtask(() {
      if (mounted) {
        context.read<KmbusBloc>().add(PageDashboardLoad());
      }
    });
  }

  // Fungsi Pull to Refresh
  Future<void> _onRefresh() async {
    final bloc = context.read<KmbusBloc>();
    bloc.add(PageDashboardLoad());

    await bloc.stream.firstWhere(
      (state) => state.status != KmbusStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KmbusBloc, KmbusState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == KmbusStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: state.message ?? "Data berhasil disimpan",
            type: SnackbarType.success,
          );
        } else if (state.status == KmbusStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal menyimpan data",
            type: SnackbarType.failed,
          );
        }
      },
      child: BlocBuilder<KmbusBloc, KmbusState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status || prev.listKmbus != curr.listKmbus,
        builder: (context, state) {
          // Menentukan kondisi global loading overlay
          final isLoading =
              state.status == KmbusStatus.loading ||
              state.status == KmbusStatus.initial ||
              state.status == KmbusStatus.onSubmit;

          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const CoreHeader(
                          title: "KM Bus",
                          customBgColor: Colors.white,
                          withBorder: true,
                        ),
                        const CoreDateTimeWidget(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 24,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: CoreButton(
                                  onPressed: () async {
                                    if (state.idShift == null) {
                                      CoreSnackbar.show(
                                        context,
                                        message:
                                            "Tidak terdapat jadwal anda hari ini.",
                                        type: SnackbarType.warning,
                                      );
                                      return;
                                    }

                                    if (!state.allowTitikAwal) {
                                      CoreSnackbar.show(
                                        context,
                                        message:
                                            "Silahkan submit titik akhir terlebih dahulu.",
                                        type: SnackbarType.warning,
                                      );
                                      return;
                                    }
                                    await context.push(
                                      '/kmbus/titik-awal/form',
                                      extra: ScheduleArgs(
                                        idShift: state.idShift!,
                                        idKoridorShift: state.idKoridorShift!,
                                        idBusShift: state.idBusShift!,
                                      ),
                                    );
                                    if (context.mounted) {
                                      context.read<KmbusBloc>().add(
                                        PageDashboardLoad(),
                                      );
                                    }
                                  },
                                  backgroundColor:
                                      state.allowTitikAwal &&
                                          state.idShift != null
                                      ? Colors.green
                                      : Colors.grey,
                                  child: const Row(
                                    spacing: 10,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.start, color: Colors.white),
                                      Text(
                                        "Titik Awal",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CoreButton(
                                  onPressed: () async {
                                    if (state.idShift == null) {
                                      CoreSnackbar.show(
                                        context,
                                        message:
                                            "Tidak terdapat jadwal anda hari ini.",
                                        type: SnackbarType.warning,
                                      );
                                      return;
                                    }

                                    if (!state.allowTitikAkhir) {
                                      CoreSnackbar.show(
                                        context,
                                        message:
                                            "Silahkan submit titik awal terlebih dahulu.",
                                        type: SnackbarType.warning,
                                      );
                                      return;
                                    }
                                    await context.push(
                                      '/kmbus/titik-akhir/form',
                                      extra: state.idKm,
                                    );
                                    if (context.mounted) {
                                      context.read<KmbusBloc>().add(
                                        PageDashboardLoad(),
                                      );
                                    }
                                  },
                                  backgroundColor: state.allowTitikAkhir
                                      ? Colors.red
                                      : Colors.grey,
                                  child: const Row(
                                    spacing: 10,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.flag, color: Colors.white),
                                      Text(
                                        "Titik Akhir",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
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
                                  await context.push('/kmbus/history');
                                  if (context.mounted) {
                                    context.read<KmbusBloc>().add(
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

                        const SizedBox(height: 10),

                        // Container(
                        //   margin: const EdgeInsets.symmetric(
                        //     vertical: 5,
                        //     horizontal: 20,
                        //   ),
                        //   child: Column(
                        //     spacing: 10,
                        //     children: [
                        //       Padding(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 5,
                        //         ),
                        //         child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             const Text(
                        //               "2026-10-12",
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.w700,
                        //               ),
                        //             ),
                        //             Container(
                        //               padding: const EdgeInsets.all(5),
                        //               decoration: BoxDecoration(
                        //                 color: Colors.blue,
                        //                 borderRadius: BorderRadius.circular(4),
                        //               ),
                        //               child: Icon(
                        //                 Icons.calendar_today,
                        //                 size: 20,
                        //                 color: Colors.white,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //       Container(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 16,
                        //           vertical: 10,
                        //         ),
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(16),
                        //           border: Border.all(
                        //             color: Colors.grey.withValues(alpha: 0.3),
                        //           ),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black.withValues(
                        //                 alpha: 0.05,
                        //               ),
                        //               blurRadius: 20,
                        //               offset: const Offset(0, 10),
                        //             ),
                        //           ],
                        //         ),
                        //         child: Row(
                        //           children: [
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text("[BUS]"),
                        //                   Text("[TITIK AKHIR] : XXX KM"),
                        //                 ],
                        //               ),
                        //             ),
                        //             const SizedBox(width: 10),
                        //             Column(
                        //               children: [
                        //                 Container(
                        //                   padding: const EdgeInsets.symmetric(
                        //                     vertical: 2,
                        //                     horizontal: 8,
                        //                   ),
                        //                   decoration: BoxDecoration(
                        //                     color: Colors.yellowAccent,
                        //                     borderRadius: BorderRadius.circular(
                        //                       99,
                        //                     ),
                        //                     border: Border.all(
                        //                       width: 1,
                        //                       color: Colors.yellow,
                        //                     ),
                        //                   ),
                        //                   child: Text(
                        //                     "PENDING",
                        //                     style: TextStyle(
                        //                       fontSize: 10,
                        //                       fontWeight: FontWeight.w600,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 const SizedBox(height: 4),
                        //                 Text(
                        //                   "20:08",
                        //                   // StringFormatter().formatHourMinute(value),
                        //                   style: const TextStyle(
                        //                     fontSize: 14,
                        //                     fontWeight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //       Container(
                        //         padding: const EdgeInsets.symmetric(
                        //           horizontal: 16,
                        //           vertical: 10,
                        //         ),
                        //         decoration: BoxDecoration(
                        //           color: Colors.white,
                        //           borderRadius: BorderRadius.circular(16),
                        //           border: Border.all(
                        //             color: Colors.grey.withValues(alpha: 0.3),
                        //           ),
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black.withValues(
                        //                 alpha: 0.05,
                        //               ),
                        //               blurRadius: 20,
                        //               offset: const Offset(0, 10),
                        //             ),
                        //           ],
                        //         ),
                        //         child: Row(
                        //           children: [
                        //             Expanded(
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text("[BUS]"),
                        //                   Text("[TITIK AWAL] : XXX KM"),
                        //                 ],
                        //               ),
                        //             ),
                        //             const SizedBox(width: 10),
                        //             Column(
                        //               children: [
                        //                 Container(
                        //                   padding: const EdgeInsets.symmetric(
                        //                     vertical: 2,
                        //                     horizontal: 8,
                        //                   ),
                        //                   decoration: BoxDecoration(
                        //                     color: Colors.greenAccent,
                        //                     borderRadius: BorderRadius.circular(
                        //                       99,
                        //                     ),
                        //                     border: Border.all(
                        //                       width: 1,
                        //                       color: Colors.green,
                        //                     ),
                        //                   ),
                        //                   child: Text(
                        //                     "APPROVED",
                        //                     style: TextStyle(
                        //                       fontSize: 10,
                        //                       fontWeight: FontWeight.w600,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 const SizedBox(height: 4),
                        //                 Text(
                        //                   "19:45",
                        //                   // StringFormatter().formatHourMinute(value),
                        //                   style: const TextStyle(
                        //                     fontSize: 14,
                        //                     fontWeight: FontWeight.w700,
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        if (state.listKmbusAuditTrail.isEmpty)
                          const Center(child: Text("Belum ada data tersimpan."))
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: state.listKmbusAuditTrail.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final data = state.listKmbusAuditTrail[index];

                              final String hourMinute =
                                  "${data.createdDate.hour.toString().padLeft(2, '0')}:${data.createdDate.minute.toString().padLeft(2, '0')}";

                              final String tanggalHariIni = data.createdDate
                                  .toIso8601String()
                                  .split('T')[0];

                              bool showHeaderTanggal = true;
                              if (index > 0) {
                                final prevData =
                                    state.listKmbusAuditTrail[index - 1];
                                final String tanggalSebelumnya = prevData
                                    .createdDate
                                    .toIso8601String()
                                    .split('T')[0];
                                if (tanggalHariIni == tanggalSebelumnya) {
                                  showHeaderTanggal = false;
                                }
                              }

                              final bool isTitikAkhir =
                                  data.dataAfter.titikAkhir != null &&
                                  data.dataAfter.titikAkhir != 0;
                              final String tipeTitik = isTitikAkhir
                                  ? "TITIK AKHIR"
                                  : "TITIK AWAL";

                              final int nilaiKm = isTitikAkhir
                                  ? (data.dataAfter.titikAkhir ?? 0)
                                  : (data.dataAfter.titikAwal ?? 0);

                              Color badgeBgColor = Colors.yellowAccent;
                              Color badgeBorderColor = Colors.yellow;

                              if (data.status.code == "APR") {
                                badgeBgColor = Colors.greenAccent.withValues(
                                  alpha: 0.3,
                                );
                                badgeBorderColor = Colors.green;
                              } else if (data.status.code == "DFT") {
                                badgeBgColor = Colors.yellowAccent.withValues(
                                  alpha: 0.4,
                                );
                                badgeBorderColor = Colors.yellow;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showHeaderTanggal)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              tanggalHariIni,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.3,
                                          ),
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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  tipeTitik == "TITIK AWAL"
                                                      ? data.noPolisi
                                                      : state
                                                            .listKmbusAuditTrail[index +
                                                                1]
                                                            .noPolisi,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  spacing: 6,
                                                  children: [
                                                    Icon(
                                                      tipeTitik == "TITIK AWAL"
                                                          ? Icons.start
                                                          : Icons.flag,
                                                      size: 18,
                                                      color:
                                                          tipeTitik ==
                                                              "TITIK AWAL"
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                    Text(
                                                      "$nilaiKm KM",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            tipeTitik ==
                                                                "TITIK AWAL"
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: badgeBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(99),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: badgeBorderColor,
                                                  ),
                                                ),
                                                child: Text(
                                                  data.status.name,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                hourMinute,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
