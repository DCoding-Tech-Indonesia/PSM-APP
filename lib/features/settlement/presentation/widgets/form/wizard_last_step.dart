import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_camera_widget.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_last_step_date_time.dart';

class WizardLastStep extends StatefulWidget {
  const WizardLastStep({super.key});

  @override
  State<WizardLastStep> createState() => _WizardLastStepState();
}

class _WizardLastStepState extends State<WizardLastStep> {
  int _totalTransaction = 0;

  Future<void> _openCamera() async {
    const ratio = 9 / 16;

    CameraAccessHelper.checkPermissions(
      context,
      onGranted: () async {
        final file = await context.push<File?>(
          '/camera',
          extra: {'ratio': ratio},
        );

        if (file == null || !mounted) return;

        context.read<SettlementBloc>().add(UploadDocument(file));
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final state = context.read<SettlementBloc>().state;

    _totalTransaction = state.detail.fold<int>(
      0,
      (sum, item) => sum + (item.value ?? 0),
    );
  }

  int _calculatePaymentTotal(
    List<SettlementDetail> details,
    List customerType,
  ) {
    int total = 0;

    for (final customer in customerType) {
      final detail = details.firstWhere((e) => e.idNasabah == customer.id);

      final qty = detail.total ?? 0;
      final value = detail.billingValue ?? 0;

      total += qty * value;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final logoMap = {
      'QRIS': 'assets/logo/qris.png',
      'BRIZI': 'assets/logo/brizzi.png',
      'DEBIT CARD': 'assets/logo/card.png',
    };

    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final paymentMethods = state.referencePayment;
        final customerType = state.referenceCustomer.toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === TOP HEADER CARD (SUMMARY INFO) ===
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.namaKoridor != '' ? state.namaKoridor : '-',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.noUnit != '' ? state.noUnit : '-',
                                style: const TextStyle(
                                  color: Color(0xFF718096),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_transit_rounded,
                                color: Color(0xFF1565C0),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ritase ${state.ritase}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Pendapatan:",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          StringFormatter().idrFormatter(_totalTransaction),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const WizardLastStepDateTime(),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // === DETAIL PENJUALAN PER METODE BAYAR ===
              ...paymentMethods.map((payment) {
                final details = state.detail
                    .where((e) => e.idPayment == payment.id)
                    .toList();

                final totalValue = _calculatePaymentTotal(
                  details,
                  customerType,
                );

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              logoMap[payment.name] ?? 'assets/logo/card.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            payment.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      ...customerType.map((customer) {
                        final detail = details
                            .cast<SettlementDetail?>()
                            .firstWhere(
                              (e) => e?.idNasabah == customer.id,
                              orElse: () => null,
                            );

                        final total = detail?.total ?? 0;
                        final value = detail?.billingValue ?? 0;
                        final subtotal = total * value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$total x ${StringFormatter().idrFormatter(value)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF718096),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    StringFormatter().idrFormatter(subtotal),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            StringFormatter().idrFormatter(totalValue),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // === FOTO BUKTI CARD ===
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Foto Bukti",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 14),

                    BlocBuilder<SettlementBloc, SettlementState>(
                      buildWhen: (prev, curr) =>
                          prev.documentPreview != curr.documentPreview,
                      builder: (context, state) {
                        return CoreCameraWidget(
                          title: "Ambil Foto Bukti",
                          imageUrl: state.documentPreview.firstOrNull?.url,
                          onTap: () {
                            if (state.documentPreview.isNotEmpty) {
                              final doc = state.documentPreview.first;

                              CoreCameraWidget.showPreviewDialog(
                                context: context,
                                imageUrl: doc.url,
                                onDelete: () {
                                  context.read<SettlementBloc>().add(
                                    RemoveDocumentById(doc.idDocument),
                                  );
                                  Navigator.pop(context);
                                },
                              );
                            } else {
                              _openCamera();
                            }
                          },
                          onRemoveImage: () {
                            final doc = state.documentPreview.first;

                            context.read<SettlementBloc>().add(
                              RemoveDocumentById(doc.idDocument),
                            );
                          },
                          instructions: const [
                            "Pastikan foto tidak buram",
                            "Pastikan bukti transaksi terlihat jelas",
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
