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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final paymentMethods = state.referencePayment;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                    bottom: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.namaKoridor != '' ? state.namaKoridor : '-',
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          state.noUnit != '' ? state.noUnit : '-',
                          style: const TextStyle(
                            color: Color(0xFF222222),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              StringFormatter().idrFormatter(_totalTransaction),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.yellow,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  state.ritase.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        WizardLastStepDateTime(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  final customerType = state.referenceCustomer.toList();

                  return Column(
                    children: paymentMethods.map((payment) {
                      final details = state.detail
                          .where((e) => e.idPayment == payment.id)
                          .toList();

                      var totalValue = 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: .15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 16),

                            ...customerType.map((customer) {
                              final detail = details
                                  .cast<SettlementDetail?>()
                                  .firstWhere(
                                    (e) => e?.idNasabah == customer.id,
                                    orElse: () => null,
                                  );

                              final total = detail?.total ?? 0;
                              final value = detail?.billingValue ?? 0;

                              totalValue += total * value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(customer.name),
                                    Text(
                                      '$total x ${StringFormatter().idrFormatter(value)}',
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const Divider(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total'),
                                Text(
                                  StringFormatter().idrFormatter(totalValue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                    bottom: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Foto Bukti",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

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

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
