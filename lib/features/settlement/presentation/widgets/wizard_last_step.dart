import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_return_value.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/wizard_last_step_date_time.dart';

class WizardLastStep extends StatefulWidget {
  const WizardLastStep({super.key});

  @override
  State<WizardLastStep> createState() => _WizardLastStepState();
}

class _WizardLastStepState extends State<WizardLastStep> {
  int _selectedPaymentId = 0;
  String _selectedDetail = '';
  int _totalTransaction = 0;

  File? _image;

  void _changeTabDetail(String val, int idPayment) {
    setState(() {
      _selectedPaymentId = idPayment;
      _selectedDetail = val;
    });
  }

  Future<void> _openCamera() async {
    const ratio = 9 / 16;

    CameraAccessHelper.checkPermissions(
      context,
      onGranted: () async {
        final result = await context.push<DocumentReturnValue?>(
          '/camera',
          extra: {'ratio': ratio, 'bloc': context.read<SettlementBloc>()},
        );

        if (result != null) {
          setState(() {
            _image = result.file;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final state = context.read<SettlementBloc>().state;

    if (state.detail.isNotEmpty) {
      _totalTransaction = state.detail.fold(0, (sum, item) => sum + item.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showPreviewDialog(DocumentPreview doc) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    child: Image.network(doc.url, fit: BoxFit.contain),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          context.read<SettlementBloc>().add(
                            RemoveDocumentById(doc.idDocument),
                          );

                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Hapus"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Tutup"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final paymentMethods = state.referencePayment;

        String getIcon(String method) {
          switch (method) {
            case "Debit Card":
              return "assets/logo/card.png";
            case "BRIZI":
              return "assets/logo/brizzi.png";
            case "CASH":
              return "assets/logo/cash.png";
            case "QRIS":
              return "assets/logo/qris.png";
            default:
              return "assets/logo/default.png";
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Text(
                    StringFormatter().idrFormatter(_totalTransaction),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  WizardLastStepDateTime(),
                ],
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paymentMethods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 16,
                  childAspectRatio: 3.0,
                ),
                itemBuilder: (context, index) {
                  final item = paymentMethods[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _changeTabDetail(item.name, item.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: _selectedDetail == item.name
                            ? LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade300,
                                ],
                              )
                            : null,
                        color: _selectedDetail == item.name
                            ? null
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedDetail == item.name
                              ? Colors.blue.shade400
                              : Colors.black.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Image.asset(
                              getIcon(item.name),
                              height: 32,
                              width: 32,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: _selectedDetail == item.name
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: _selectedDetail == item.name
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              if (_selectedDetail.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.15),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Rincian Pembayaran",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Metode",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _selectedDetail,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                      ),

                      BlocBuilder<SettlementBloc, SettlementState>(
                        builder: (context, state) {
                          final customerType = state.referenceCustomer.toList();

                          final details = state.detail
                              .where((e) => e.idPayment == _selectedPaymentId)
                              .toList();

                          var totalValue = 0;

                          return Column(
                            children: [
                              Column(
                                children: customerType.map((customer) {
                                  final detail = details
                                      .cast<SettlementDetail?>()
                                      .firstWhere(
                                        (e) => e?.idNasabah == customer.id,
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
                                }).toList(),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total"),
                                  Text(
                                    StringFormatter().idrFormatter(totalValue),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Foto Bukti",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  BlocBuilder<SettlementBloc, SettlementState>(
                    buildWhen: (prev, curr) =>
                        prev.documentPreview != curr.documentPreview,
                    builder: (context, state) {
                      if (state.documentPreview.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return BlocBuilder<SettlementBloc, SettlementState>(
                        buildWhen: (prev, curr) =>
                            prev.documentPreview != curr.documentPreview,
                        builder: (context, state) {
                          final hasImage = state.documentPreview.isNotEmpty;

                          if (!hasImage) {
                            return const SizedBox.shrink();
                          }

                          final doc = state.documentPreview.first;

                          return GestureDetector(
                            onTap: () => _showPreviewDialog(doc),
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(doc.url, fit: BoxFit.cover),

                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.2),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  BlocBuilder<SettlementBloc, SettlementState>(
                    buildWhen: (prev, curr) =>
                        prev.documentPreview != curr.documentPreview,
                    builder: (context, state) {
                      final theme = Theme.of(context);
                      final isEmpty =
                          state.documentPreview.isEmpty && _image == null;

                      if (!isEmpty) {
                        return SizedBox();
                      } else {
                        return InkWell(
                          onTap: _openCamera,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: isEmpty ? 200 : 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: _image != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          _image!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _image = null;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: isEmpty ? 48 : 32,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isEmpty
                                            ? "Ambil Foto Bukti"
                                            : "Tambah Foto Lain",
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: isEmpty ? 16 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
