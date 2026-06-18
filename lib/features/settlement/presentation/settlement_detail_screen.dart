import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

import '../domain/entities/settlement_detail.dart';
import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_state.dart';

class SettlementDetailScreen extends StatefulWidget {
  const SettlementDetailScreen({
    super.key,
    required this.idAuditTrail,
    required this.isDraft,
  });

  final int idAuditTrail;
  final bool isDraft;

  @override
  State<SettlementDetailScreen> createState() => _SettlementDetailScreenState();
}

class _SettlementDetailScreenState extends State<SettlementDetailScreen> {

  Future<void> _showCancelDraftVerification(
      BuildContext context,
      int id,
      ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan pembatalan draft?',
          desc: 'Data yang anda batalkan perlu dilakukan pengajuan kembali.',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<SettlementBloc>().add(CancelTaskDraft(id));
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageHistoryLoad(widget.idAuditTrail));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SettlementStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: "Gagal melakukan pembatalan draft",
            type: SnackbarType.warning,
          );
        }
        if (state.status == SettlementStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: "Draft berhasil dibatalkan",
            type: SnackbarType.success,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              if (state.status == SettlementStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == SettlementStatus.error) {
                return Center(child: Text(state.message ?? 'Terjadi kesalahan'));
              }

              return Column(
                children: [
                  const CoreHeader(
                    title: 'Detail Settlement',
                    customBgColor: Colors.white,
                    withBorder: true,
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Builder(
                        builder: (context) {
                          final paymentMethods = state.referencePayment;
                          final customerType = state.referenceCustomer;

                          final logoMap = {
                            'QRIS': 'assets/logo/qris.png',
                            'BRIZI': 'assets/logo/brizzi.png',
                            'DEBIT CARD': 'assets/logo/card.png',
                          };

                          int totalTransaction = state.detail.fold<int>(
                            0,
                            (sum, item) =>
                                sum +
                                ((item.total ?? 0) * (item.billingValue ?? 0)),
                          );

                          int calculatePaymentTotal(
                            List<SettlementDetail> details,
                          ) {
                            int total = 0;

                            for (final item in details) {
                              total +=
                                  (item.total ?? 0) * (item.billingValue ?? 0);
                            }

                            return total;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.namaKoridor.isNotEmpty
                                                ? state.namaKoridor
                                                : '-',
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                          decoration: BoxDecoration(
                                              color: !widget.isDraft ? Colors.greenAccent : Colors.yellowAccent,
                                              borderRadius: BorderRadius.circular(99),
                                              border: Border.all(width: 1, color: !widget.isDraft ? Colors.green : Colors.yellow)
                                          ),
                                          child: Text(!widget.isDraft ? "Approved" : "Draft", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      state.noUnit.isNotEmpty
                                          ? state.noUnit
                                          : '-',
                                      style: const TextStyle(color: Colors.grey),
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          StringFormatter().idrFormatter(
                                            totalTransaction,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),

                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.yellowAccent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              state.ritase.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              ...paymentMethods.map((payment) {
                                final details = state.detail
                                    .where((e) => e.idPayment == payment.id)
                                    .toList();

                                final totalValue = calculatePaymentTotal(details);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Image.asset(
                                              logoMap[payment.name] ??
                                                  'assets/logo/card.png',
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Text(
                                            payment.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      ...customerType.map((customer) {
                                        final detail = details
                                            .cast<SettlementDetail?>()
                                            .firstWhere(
                                              (e) => e?.idNasabah == customer.id,
                                              orElse: () => null,
                                            );

                                        final qty = detail?.total ?? 0;

                                        final value = detail?.billingValue ?? 0;

                                        final subtotal = qty * value;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customer.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '$qty x ${StringFormatter().idrFormatter(value)}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    StringFormatter()
                                                        .idrFormatter(subtotal),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),

                                      const Divider(),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            StringFormatter().idrFormatter(
                                              totalValue,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
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

                                    if (state.documentPreview.isNotEmpty)
                                      InkWell(
                                        onTap: () {
                                          final doc = state.documentPreview.first;

                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black87,
                                            builder: (_) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      child: InteractiveViewer(
                                                        child: Image.network(
                                                          doc.url,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 16),

                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: OutlinedButton.icon(
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          side: const BorderSide(
                                                            color: Colors.white,
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                        label: const Text(
                                                          "Tutup",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 220,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.blue.withValues(
                                                alpha: .3,
                                              ),
                                            ),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  state.documentPreview.first.url,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (context, child, progress) {
                                                        if (progress == null)
                                                          return child;

                                                        return const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      },
                                                  errorBuilder: (_, __, ___) {
                                                    return const Center(
                                                      child: Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 48,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(16),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black.withValues(
                                                          alpha: .2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove_red_eye_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 220,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Tidak ada foto bukti',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              if (widget.isDraft)
                                CoreButton(
                                  onPressed: () async {
                                    await _showCancelDraftVerification(context, widget.idAuditTrail);
                                  },
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    "Hapus Draft",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CoreButton(
                      backgroundColor: Colors.blue,
                      width: double.infinity,
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Kembali",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
