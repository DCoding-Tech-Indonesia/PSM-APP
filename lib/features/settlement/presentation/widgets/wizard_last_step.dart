import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_return_value.dart';
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
  int _indexDetail = 0;
  String _selectedDetail = '';
  int _totalTransaction = 0;

  File? _image;

  void _changeTabDetail(int index, String val) {
    var selectedIndex = 0;

    if (index == 0) {
      selectedIndex = 0;
    } else if (index == 1) {
      selectedIndex = 3;
    } else if (index == 2) {
      selectedIndex = 5;
    } else {
      selectedIndex = 9;
    }

    setState(() {
      _indexDetail = selectedIndex;
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
                    child: Image.network(
                      doc.url,
                      fit: BoxFit.contain,
                    ),
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
        final paymentMethods = state.labelPayment;
        final customerTypes = state.labelCustomer;
        final customerTypesFiltered = customerTypes.toSet().toList();

        String getIcon(String method) {
          switch (method) {
            case "Credit Card":
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
                      fontSize: 20,
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
                  const SizedBox(height: 4),
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
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  final item = paymentMethods[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _changeTabDetail(index, item);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: _selectedDetail == item
                            ? LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade400,
                                ],
                              )
                            : null,
                        color: _selectedDetail == item ? null : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Image.asset(
                              getIcon(item),
                              height: 26,
                              width: 26,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedDetail == item
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _selectedDetail == item
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tipe Pembayaran"),
                        Text(
                          _selectedDetail,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ...customerTypesFiltered.asMap().entries.map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.value),
                            BlocBuilder<SettlementBloc, SettlementState>(
                              builder: (context, state) {
                                return Text(
                                  '${state.detail[_indexDetail + data.key].total} x ${StringFormatter().idrFormatter(state.detailInput[_indexDetail + data.key].value)}',
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(),

                    BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, state) {
                        final total = _selectedDetail.isEmpty
                            ? 0
                            : customerTypesFiltered.asMap().entries.fold(0, (
                                sum,
                                entry,
                              ) {
                                final index = _indexDetail + entry.key;

                                if (index >= state.detail.length) {
                                  return sum;
                                }

                                return sum +
                                    state.detail[index].total *
                                        state.detailInput[index].value;
                              });

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              StringFormatter().idrFormatter(total),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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

                      return SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.documentPreview.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final doc = state.documentPreview[index];

                            return GestureDetector(
                              onTap: () => _showPreviewDialog(doc),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Image.network(doc.url),
                              
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.15),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  BlocBuilder<SettlementBloc, SettlementState>(
                    buildWhen: (prev, curr) => prev.documentPreview != curr.documentPreview,
                    builder: (context, state) {
                      if(state.documentPreview.isEmpty) {
                        return InkWell(
                          onTap: _openCamera,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: _image != null
                                ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
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
                                      borderRadius: BorderRadius.circular(100),
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
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Ambil Foto",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: _openCamera,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 110,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: _image != null
                                ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
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
                                      borderRadius: BorderRadius.circular(100),
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
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tambah Foto",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }
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
