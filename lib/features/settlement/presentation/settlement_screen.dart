import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_skeleton_widget.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/dashboard/draft_settlement_card_single.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/history_settlement_card.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_header.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<SettlementBloc>();

    bloc.add(PageDashboardLoad());

    await bloc.stream.firstWhere(
      (state) => state.status != SettlementStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
          final isInitialLoading = (state.status == SettlementStatus.loading ||
                  state.status == SettlementStatus.initial) &&
              (state.listTaskAuditTrail?.isEmpty ?? true);
          final isLoading = false; // No blocking overlay needed for initial loading anymore

          return Stack(
            children: [
              Scaffold(
                backgroundColor: const Color(0xFFF5F7FA),
                body: SafeArea(
                  child: Column(
                    children: [
                      const SettlementHeader(),
                      const CoreDateTimeWidget(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: const Color(0xFF1565C0),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
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

                            DraftSettlementCardSingle(
                              datas: state.listTaskAuditTrail,
                              idShift: state.idShift ?? 0,
                              idKoridor: state.idKoridorShift ?? 0,
                              idBus: state.idBusShift ?? 0,
                              ritaseKe: state.ritase,
                              isActive: state.allowInput,
                              ctaDisabledMessage: state.ctaValidationMessage,
                            ),

                            // === HISTORY HEADER ===
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Riwayat Terakhir',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await context.push('/settlement/history');

                                      if (context.mounted) {
                                        context.read<SettlementBloc>().add(
                                          PageDashboardLoad(),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFDBEAFE),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Lihat Semua',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 10,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // === HISTORY LIST / EMPTY STATE ===
                            if (state.listTaskAuditTrail.isEmpty)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.history_rounded,
                                        size: 32,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Belum Ada Riwayat",
                                      style: TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Data settlement akan muncul di sini",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.listTaskAuditTrail.length > 10
                                    ? 10
                                    : state.listTaskAuditTrail.length,
                                itemBuilder: (context, index) {
                                  final item = state.listTaskAuditTrail[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    child: HistorySettlementCard(data: item),
                                  );
                                  },
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                    ),
                  ],
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSkeletonItems() {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
            children: [
              Row(
                children: [
                  const CoreSkeletonWidget(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(12))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CoreSkeletonWidget(width: 140, height: 16),
                        SizedBox(height: 8),
                        CoreSkeletonWidget(width: 80, height: 12),
                      ],
                    ),
                  ),
                  const CoreSkeletonWidget(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(16))),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CoreSkeletonWidget(width: 80, height: 10),
                        SizedBox(height: 6),
                        CoreSkeletonWidget(width: 120, height: 16),
                      ],
                    ),
                    const CoreSkeletonWidget(width: 60, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
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
}
