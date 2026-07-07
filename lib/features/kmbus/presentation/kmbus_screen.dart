import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/entity/schedule_args.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_skeleton_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_args.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';

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
          final isInitialLoading = (state.status == KmbusStatus.loading ||
                  state.status == KmbusStatus.initial) &&
              (state.listKmbus?.isEmpty ?? true);
          final isLoading = state.status == KmbusStatus.onSubmit;

          final activeBus = state.referenceBus.firstWhere(
            (e) => e.id == (state.idBusShift ?? state.idBus),
            orElse: () => const ReferenceDetail(id: 0, code: '', name: '-'),
          );

          final activeKoridor = state.referenceKoridor.firstWhere(
            (e) => e.id == (state.idKoridorShift ?? state.idKoridor),
            orElse: () => const ReferenceDetail(id: 0, code: '', name: '-'),
          );

          return Stack(
            children: [
               Scaffold(
                backgroundColor: Colors.grey.shade50,
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
                        const SizedBox(height: 12),
                        if (isInitialLoading)
                          ..._buildSkeletonItems()
                        else ...[
                          // === VEHICLE INFO CARD ===
                          if (state.checkinData != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.directions_bus_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unit ${activeBus.name}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          activeKoridor.name,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (state.checkinData?.ritaseKe != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        'Ritase ${state.checkinData!.ritaseKe % 1 == 0 ? state.checkinData!.ritaseKe.toInt() : state.checkinData!.ritaseKe}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF718096), Color(0xFF4A5568)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A5568).withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_bus_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Belum Check-In",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Silakan lakukan Check-In di Time Table terlebih dahulu.",
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
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
                          const SizedBox(height: 16),

                          // === ACTION BUTTON ===
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildActionButton(
                              icon: Icons.add_circle_outline_rounded,
                              label: 'Input KM Keberangkatan',
                              isEnabled: state.allowTitikAwal,
                              enabledColors: const [
                                Color(0xFF2E7D32),
                                Color(0xFF43A047),
                              ],
                              onPressed: () async {
                                if (!state.allowTitikAwal) {
                                  CoreSnackbar.show(
                                    context,
                                    message: state.disabledCtaMessage,
                                    type: SnackbarType.warning,
                                  );
                                  return;
                                }
                                final result = await context.push(
                                  '/kmbus/titik-awal/form',
                                  extra: ScheduleArgs(
                                    idShift: state.idShift ?? 0,
                                    idKoridorShift: state.idKoridorShift ?? 0,
                                    idBusShift: state.idBusShift ?? 0,
                                    idAuditTrail: null,
                                  ),
                                );

                                if (context.mounted || result == true) {
                                  context.read<KmbusBloc>().add(
                                    PageDashboardLoad(),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

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
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF212121),
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Lihat Semua',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 11,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ],
                                  ),
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
                            separatorBuilder: (_, _) =>
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
                                      // Header: Bus Icon + No Polisi | Time
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.directions_bus_rounded,
                                                size: 16,
                                                color: Color(0xFF1565C0),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                tipeTitik == "TITIK AWAL" ||
                                                        (index + 1) >= state.listKmbusAuditTrail.length
                                                    ? data.noPolisi
                                                    : state.listKmbusAuditTrail[index + 1].noPolisi,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF2D3748),
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            hourMinute,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF718096),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
                                      ),
                                      // Body: KM Info (Left) | Status Badge (Right)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                tipeTitik == "TITIK AWAL"
                                                    ? Icons.play_arrow_rounded
                                                    : Icons.flag_rounded,
                                                color: tipeTitik == "TITIK AWAL"
                                                    ? const Color(0xFF2E7D32)
                                                    : const Color(0xFFC62828),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tipeTitik == "TITIK AWAL"
                                                        ? "KM Keberangkatan (Awal)"
                                                        : "KM Kedatangan (Akhir)",
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF718096),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "$nilaiKm KM",
                                                    style: TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: tipeTitik == "TITIK AWAL"
                                                          ? const Color(0xFF2E7D32)
                                                          : const Color(0xFFC62828),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: data.status.code == "APR"
                                                  ? const Color(0xFFE8F5E9)
                                                  : const Color(0xFFFFFDE7),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: data.status.code == "APR"
                                                    ? const Color(0xFFC8E6C9)
                                                    : const Color(0xFFFFF9C4),
                                              ),
                                            ),
                                            child: Text(
                                              data.status.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: data.status.code == "APR"
                                                    ? const Color(0xFF2E7D32)
                                                    : const Color(0xFFF57F17),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (isDraft) {
                                cardItem = Dismissible(
                                  key: Key(data.id.toString()),
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (direction ==
                                        DismissDirection.endToStart) {
                                      final bool? shouldSubmit =
                                          await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext ctx) {
                                          return CoreBottomModalVerification(
                                            title: "Submit Data KM Bus",
                                            desc:
                                                "Apakah Anda yakin ingin melakukan submit untuk data $tipeTitik ($nilaiKm KM)?",
                                            confirmText: "Ya, Submit",
                                            cancelText: "Batal",
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
                                      final bool? shouldEdit =
                                          await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext ctx) {
                                          return CoreBottomModalVerification(
                                            title: "Edit Draft Data KM Bus",
                                            desc:
                                                "Apakah Anda yakin ingin mengubah draft $tipeTitik ini?",
                                            confirmText: "Ya, Ubah",
                                            cancelText: "Batal",
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
                                      borderRadius: BorderRadius.circular(20),
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
                                      borderRadius: BorderRadius.circular(20),
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
                                        padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_rounded,
                                              size: 13,
                                              color: Color(0xFF718096),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              tanggalHariIni,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: Color(0xFF4A5568),
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

  List<Widget> _buildSkeletonItems() {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CoreSkeletonWidget(width: 140, height: 18),
              const SizedBox(height: 12),
              CoreSkeletonWidget(width: double.infinity, height: 20),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(child: CoreSkeletonWidget(width: double.infinity, height: 50, borderRadius: BorderRadius.circular(14))),
            const SizedBox(width: 12),
            Expanded(child: CoreSkeletonWidget(width: double.infinity, height: 50, borderRadius: BorderRadius.circular(14))),
          ],
        ),
      ),
      const SizedBox(height: 24),
      ...List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CoreSkeletonWidget(width: 100, height: 14),
                    CoreSkeletonWidget(width: 60, height: 20, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
                const SizedBox(height: 16),
                CoreSkeletonWidget(width: 180, height: 18),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CoreSkeletonWidget(width: 120, height: 12),
                    CoreSkeletonWidget(width: 60, height: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      const SizedBox(height: 24),
    ];
  }

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
}
