import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_document.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';

class SettlementAddScreenBackup extends StatefulWidget {
  const SettlementAddScreenBackup({super.key});

  @override
  State<SettlementAddScreenBackup> createState() => _SettlementAddScreenBackupState();
}

class _SettlementAddScreenBackupState extends State<SettlementAddScreenBackup> {
  File? _image;

  final _processIdC = TextEditingController();
  final _codeC = TextEditingController();

  Future<void> _openCamera() async {
    const ratio = 16 / 9;

    CameraAccessHelper.checkPermissions(
      context,
      onGranted: () async {
        final result = await context.push<File?>('/camera', extra: ratio);

        if (result != null) {
          setState(() {
            _image = result;
          });
        }
      },
    );
  }

  void _previewImage() {
    if (_image == null) return;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    InteractiveViewer(child: Image.file(_image!)),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(
                      gradient: CoreStyling.coreDeleteButtonGradient,
                      icon: Icons.delete,
                      onTap: () {
                        setState(() => _image = null);
                        Navigator.pop(context);
                      },
                    ),
                    _circleButton(
                      gradient: CoreStyling.coreActiveButtonGradient,
                      icon: Icons.camera_alt,
                      onTap: () {
                        Navigator.pop(context);
                        _openCamera();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleButton({
    required Gradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _submit() {
    final bloc = context.read<SettlementBloc>();

    bloc.add(SettlementFieldChanged("processId", _processIdC.text));
    bloc.add(SettlementFieldChanged("auditTrailId", 1));
    bloc.add(SettlementFieldChanged("idBus", 1));
    bloc.add(SettlementFieldChanged("code", _codeC.text));
    bloc.add(SettlementFieldChanged("idKoridor", 1));
    bloc.add(SettlementFieldChanged("idShift", 1));

    bloc.add(AddDetail(
      SettlementDetail(
        idPayment: 1,
        idNasabah: 1,
        total: 1,
        value: 1,
      ),
    ));

    bloc.add(AddDocument(
      SettlementDocument(
        idDocument: 1,
        idDocumentType: 1,
      ),
    ));

    bloc.add(SubmitSettlement());
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _processIdC.dispose();
    _codeC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: const Text("Submit Settlement"),
      ),
      body: BlocListener<SettlementBloc, SettlementState>(
        listener: (context, state) {
          if (state.status == SettlementStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil submit")),
            );
          } else if (state.status == SettlementStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Error")),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      _input("Process ID", _processIdC),
                      const SizedBox(height: 12),
                      _input("Code", _codeC),

                      const SizedBox(height: 20),

                      /// IMAGE
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Upload Foto Settlement",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _image == null ? _openCamera : _previewImage,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 4,
                                  child: _image == null
                                      ? const Center(
                                    child: Text("Ambil Foto"),
                                  )
                                      : Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// BUTTON
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: CoreStyling.coreActiveButtonGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GestureDetector(
                  onTap: _submit,
                  child: BlocBuilder<SettlementBloc, SettlementState>(
                    builder: (context, state) {
                      if (state.status == SettlementStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      return const Text(
                        "Simpan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}