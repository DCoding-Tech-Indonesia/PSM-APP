import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/entity/schedule_args.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_args.dart';
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

    Future.microtask(() {
      if (mounted) {
        context.read<KmbusBloc>().add(PageDashboardLoad());
      }
    });
  }

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
      listenWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.submitWorkflowStatus != curr.submitWorkflowStatus,
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
        if (state.submitWorkflowStatus == SubmitWorkflowStatus.success) {
          CoreSnackbar.show(
            context,
            message: "Data berhasil di-submit!",
            type: SnackbarType.success,
          );

          context.read<KmbusBloc>().add(PageDashboardLoad());
        } else if (state.submitWorkflowStatus == SubmitWorkflowStatus.failed) {
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal melakukan submit data",
            type: SnackbarType.failed,
          );
        }
      },
      child: BlocBuilder<KmbusBloc, KmbusState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status || prev.listKmbus != curr.listKmbus,
        builder: (context, state) {
          final isLoading =
              state.status == KmbusStatus.loading ||
              state.status == KmbusStatus.initial ||
              state.status == KmbusStatus.onSubmit;

          return Stack(
            children: [
              Scaffold(
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const CoreHeader(
                          title: "KM Bus",
                          subtitle: "Data KM Bus",
                        ),
                        const CoreDateTimeWidget(),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (!state.allowTitikAwal) {
                                  CoreSnackbar.show(
                                    context,
                                    message: state.disabledCtaMessage,
                                    type: SnackbarType.warning,
                                  );

                                  return;
                                }
                                await context.push(
                                  '/kmbus/titik-awal/form',
                                  extra: ScheduleArgs(
                                    idShift: state.idShift ?? 0,
                                    idKoridorShift: state.idKoridorShift ?? 0,
                                    idBusShift: state.idBusShift ?? 0,
                                    idAuditTrail: null,
                                  ),
                                );

                                if (context.mounted) {
                                  context.read<KmbusBloc>().add(
                                    PageDashboardLoad(),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: state.allowTitikAwal
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2E7D32),
                                            Color(0xFF43A047),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFF454545),
                                            Color(0xFF9a9a9a),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Input KM Keberangkatan",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

                              final bool isDraft = data.status.code == "DFT";

                              if (data.status.code == "APR") {
                                badgeBgColor = Colors.greenAccent;
                                badgeBorderColor = Colors.green;
                              } else if (isDraft) {
                                badgeBgColor = Colors.yellowAccent;
                                badgeBorderColor = Colors.yellow;
                              }

                              Widget cardItem = Container(
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tipeTitik == "TITIK AWAL" ||
                                                    (index + 1) >=
                                                        state
                                                            .listKmbusAuditTrail
                                                            .length
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
                                                color: tipeTitik == "TITIK AWAL"
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              Text(
                                                "$nilaiKm KM",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      tipeTitik == "TITIK AWAL"
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
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeBgColor,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
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
                              );

                              if (isDraft) {
                                cardItem = Dismissible(
                                  key: Key(data.id.toString()),
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      final bool?
                                      shouldSubmit = await showModalBottomSheet<bool>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (BuildContext ctx) {
                                          return Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: 48,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  "Submit Data KM Bus",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Apakah Anda yakin ingin melakukan submit untuk data $tipeTitik ($nilaiKm KM)?",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          side:
                                                              const BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(false),
                                                        child: const Text(
                                                          "Batal",
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(true),
                                                        child: const Text(
                                                          "Ya, Submit",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );

                                      if (shouldSubmit == true) {
                                        context.read<KmbusBloc>().add(
                                          SubmitWorkflow('Done', data.id),
                                        );
                                      }
                                      return false;
                                    } else if (direction ==
                                        DismissDirection.startToEnd) {
                                      final bool?
                                      shouldEdit = await showModalBottomSheet<bool>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (BuildContext ctx) {
                                          return Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                const Icon(
                                                  Icons.edit_note_rounded,
                                                  size: 48,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  "Edit Draft Data KM Bus",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Apakah Anda yakin ingin mengubah draft $tipeTitik ini?",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: OutlinedButton(
                                                        style: OutlinedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          side:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .orange,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(false),
                                                        child: const Text(
                                                          "Batal",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.orange,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(true),
                                                        child: const Text(
                                                          "Ya, Edit",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );

                                      if (shouldEdit == true) {
                                        if (tipeTitik == "TITIK AWAL") {
                                          await context.push(
                                            '/kmbus/titik-awal/form',
                                            extra: ScheduleArgs(
                                              idShift: state.idShift ?? 0,
                                              idKoridorShift:
                                                  state.idKoridorShift ?? 0,
                                              idBusShift: state.idBusShift ?? 0,
                                              idAuditTrail: data.id,
                                            ),
                                          );
                                        } else {
                                          await context.push(
                                            '/kmbus/titik-akhir/form',
                                            extra: TitikAkhirArgs(
                                              idKm: state.idKm!,
                                              idAuditTrail: data.id,
                                            ),
                                          );
                                        }

                                        if (context.mounted) {
                                          context.read<KmbusBloc>().add(
                                            PageDashboardLoad(),
                                          );
                                        }
                                      }
                                      return false;
                                    }
                                    return false;
                                  },
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade600,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "Edit Draft",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  secondaryBackground: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Submit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.send, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  child: cardItem,
                                );
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
                                    cardItem,
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
