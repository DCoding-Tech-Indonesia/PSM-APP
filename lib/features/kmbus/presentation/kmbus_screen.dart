import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/presentations/entity/schedule_args.dart';
import 'package:travis/core/presentations/widgets/core_date_time_widget.dart';
import 'package:travis/core/presentations/widgets/core_skeleton_widget.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/features/kmbus/domain/entities/titik_akhir_args.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_state.dart';

import 'bloc/kmbus_bloc.dart';
import 'bloc/kmbus_event.dart';

class KmbusScreen extends StatefulWidget {
  const KmbusScreen({super.key});

  @override
  State<KmbusScreen> createState() => _KmbusScreenState();
}

class _KmbusScreenState extends State<KmbusScreen> {
  bool _isIncompleteExpanded = false;

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
            prev.status != curr.status ||
            prev.listKmbusAuditTrail != curr.listKmbusAuditTrail,
        builder: (context, state) {
          final isInitialLoading =
              (state.status == KmbusStatus.loading ||
                  state.status == KmbusStatus.initial) &&
              (state.listKmbusAuditTrail.isEmpty ?? true);
          final isLoading = state.status == KmbusStatus.onSubmit;

          final activeBusName = state.noUnit ?? '-';
          final activeKoridorName = state.namaKoridor ?? '-';

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
                        const SizedBox(height: 4),
                        if (isInitialLoading)
                          ..._buildSkeletonItems()
                        else ...[
                          // === VEHICLE INFO CARD ===
                          if (state.checkinData != null)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1565C0),
                                    Color(0xFF1E88E5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1565C0,
                                    ).withValues(alpha: 0.15),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unit $activeBusName',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          activeKoridorName,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF718096),
                                    Color(0xFF4A5568),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4A5568,
                                    ).withValues(alpha: 0.15),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                          const SizedBox(height: 8),

                          if (state.listKmbusAuditTrail.isNotEmpty) ...[
                            ...state.listKmbusAuditTrail
                                .where((e) {
                                  final todayString = DateTime.now()
                                      .toIso8601String()
                                      .split('T')[0];
                                  final createdDateString = e.createdDate
                                      .toLocal()
                                      .toIso8601String()
                                      .split('T')[0];
                                  final bool isSubmitted =
                                      e.dataAfter.isSubmit ?? false;
                                  return e.status.code == "DFT" &&
                                      createdDateString == todayString &&
                                      !isSubmitted;
                                })
                                .map((draft) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.orange.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final result = await context.push(
                                          '/kmbus/titik-awal/form',
                                          extra: ScheduleArgs(
                                            idShift: state.idShift ?? 0,
                                            idKoridorShift:
                                                state.idKoridorShift ?? 0,
                                            idBusShift: state.idBusShift ?? 0,
                                            idAuditTrail: draft.id,
                                          ),
                                        );
                                        if (context.mounted && result == true) {
                                          context.read<KmbusBloc>().add(
                                            PageDashboardLoad(),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withValues(
                                                  alpha: 0.15,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.orange,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Draft KM Awal Tertunda",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.orange,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "KM: ${draft.dataAfter.titikAwal ?? '-'} KM • Ketuk untuk mengirim ulang",
                                                    style: TextStyle(
                                                      color: Colors
                                                          .orange
                                                          .shade800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.orange,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ],

                          // Incomplete KM entries (have awal, missing akhir)
                          if (state.listKmbus.isNotEmpty) ...[
                            ...state.listKmbus
                                .where((km) =>
                                    (km.titikAkhir == null ||
                                        km.titikAkhir == 0) &&
                                    (km.titikAwal != null &&
                                        km.titikAwal != 0))
                                .toList()
                                .take(_isIncompleteExpanded
                                    ? state.listKmbus
                                            .where((km) =>
                                                (km.titikAkhir == null ||
                                                    km.titikAkhir == 0) &&
                                                (km.titikAwal != null &&
                                                    km.titikAwal != 0))
                                            .length
                                    : 3)
                                .map((incomplete) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.red.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        final result = await context.push<bool>(
                                          '/kmbus/titik-akhir/form',
                                          extra: TitikAkhirArgs(
                                            idKm: incomplete.id ?? 0,
                                            idAuditTrail: 0,
                                          ),
                                        );
                                        if (context.mounted && result == true) {
                                          context.read<KmbusBloc>().add(
                                            PageDashboardLoad(),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.15,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.info_rounded,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Titik Akhir Belum Diisi",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "KM Awal: ${incomplete.titikAwal ?? '-'} KM • Ketuk untuk melanjutkan",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade800,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.red,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            if ((state.listKmbus
                                    .where((km) =>
                                        (km.titikAkhir == null ||
                                            km.titikAkhir == 0) &&
                                        (km.titikAwal != null &&
                                            km.titikAwal != 0))
                                    .length) >
                                3)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isIncompleteExpanded =
                                            !_isIncompleteExpanded;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red[700],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isIncompleteExpanded
                                              ? 'Sembunyikan'
                                              : 'Tampilkan Semua (${state.listKmbus.where((km) => (km.titikAkhir == null || km.titikAkhir == 0) && (km.titikAwal != null && km.titikAwal != 0)).length - 3} lagi)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          _isIncompleteExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],

                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
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
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await context.push('/kmbus/history');
                                    if (context.mounted) {
                                      context.read<KmbusBloc>().add(
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

                          if (state.listKmbus.isEmpty)
                            const Center(
                              child: Text("Belum ada data tersimpan."),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: state.listKmbus.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = state.listKmbus[index];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header: Date | Unit Badge
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                  item.tanggalKm ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF2D3748),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFF7FAFC,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE2E8F0,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                "${item.bus?.platNomor ?? '-'} • ${item.bus?.nomorLambung ?? '-'}",
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
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xFFEDF2F7),
                                          ),
                                        ),

                                        // Timeline KM Route
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
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
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.circle,
                                                    size: 8,
                                                    color: Color(0xFFC62828),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "KM Awal (Mulai)",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                              0xFF718096,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${item.titikAwal ?? 0} KM",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Color(
                                                                  0xFF2E7D32,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 18),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text(
                                                          "KM Akhir (Selesai)",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                              0xFF718096,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          item.titikAkhir !=
                                                                  null
                                                              ? '${item.titikAkhir} KM'
                                                              : 'Belum Diisi',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                item.titikAkhir !=
                                                                    null
                                                                ? const Color(
                                                                    0xFFC62828,
                                                                  )
                                                                : Colors.orange,
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
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Color(0xFFEDF2F7),
                                          ),
                                        ),

                                        // Footer: Corridor + Total Distance
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .directions_bus_rounded,
                                                    size: 15,
                                                    color: Color(0xFF1565C0),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      item.koridor?.name ??
                                                          "Koridor N/A",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 13,
                                                        color: Color(
                                                          0xFF2D3748,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF1565C0,
                                                ).withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF1565C0,
                                                  ).withValues(alpha: 0.15),
                                                ),
                                              ),
                                              child: Text(
                                                "Total: ${item.totalTempuh ?? 0} km",
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
                              },
                            ),

                        ],
                      ],
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
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

                    if (context.mounted && result == true) {
                      context.read<KmbusBloc>().add(PageDashboardLoad());
                    }
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
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
      // Vehicle Info Card Skeleton (matches VEHICLE INFO CARD)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CoreSkeletonWidget(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CoreSkeletonWidget(width: 100, height: 18),
                    const SizedBox(height: 6),
                    const CoreSkeletonWidget(width: 150, height: 13),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              CoreSkeletonWidget(
                width: 70,
                height: 24,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      // History Header Skeleton
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
      // History Cards Skeleton (matches KM Bus card items)
      ...List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
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
                    Row(
                      children: const [
                        CoreSkeletonWidget(
                          width: 16,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        SizedBox(width: 6),
                        CoreSkeletonWidget(width: 90, height: 14),
                      ],
                    ),
                    const CoreSkeletonWidget(width: 40, height: 14),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEDF2F7),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CoreSkeletonWidget(
                          width: 16,
                          height: 16,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            CoreSkeletonWidget(width: 120, height: 11),
                            SizedBox(height: 4),
                            CoreSkeletonWidget(width: 60, height: 14),
                          ],
                        ),
                      ],
                    ),
                    CoreSkeletonWidget(
                      width: 60,
                      height: 20,
                      borderRadius: BorderRadius.circular(8),
                    ),
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

}
