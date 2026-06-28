import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_camera_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';

import 'bloc/kmbus_event.dart';

class KmbusTitikAkhirFormScreen extends StatefulWidget {
  const KmbusTitikAkhirFormScreen({super.key, required this.idAuditTrail});

  final int idAuditTrail;

  @override
  State<KmbusTitikAkhirFormScreen> createState() =>
      _KmbusTitikAkhirFormScreenState();
}

class _KmbusTitikAkhirFormScreenState extends State<KmbusTitikAkhirFormScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<KmbusBloc>().add(
        KmbusTitikAkhirInputLoad(widget.idAuditTrail),
      );
    });
  }

  Future<void> _showSubmitDraftModal(BuildContext context, int id) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: "Draft berhasil disimpan.",
          desc: "Ingin langsung melakukan submit data?",
          onCancel: () => {Navigator.pop(modalContext, false)},
          onConfirm: () => {Navigator.pop(modalContext, true)},
        );
      },
    );

    if (isConfirm == true) {
      context.read<KmbusBloc>().add(SubmitWorkflow("Done", id));
    } else {
      context.pop();
    }
  }

  void _showEditOdometerDialog(BuildContext context, String? currentOcr) {
    final controller = TextEditingController(
      text: currentOcr == "-" ? "" : currentOcr,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Odometer'),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Masukkan nilai odometer baru',
                labelText: 'Nilai Odometer',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = int.tryParse(controller.text);
                if (newValue != null) {
                  context.read<KmbusBloc>().add(EditOdometerAkhir(newValue));
                  Navigator.pop(dialogContext);
                } else {
                  CoreSnackbar.show(
                    dialogContext,
                    message: "Masukkan angka yang valid.",
                    type: SnackbarType.failed,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    Future<void> _openCamera() async {
      const ratio = 16 / 9;

      CameraAccessHelper.checkPermissions(
        context,
        onGranted: () async {
          final file = await context.push<File?>(
            '/camera',
            extra: {'ratio': ratio},
          );

          if (file == null || !context.mounted) return;

          context.read<KmbusBloc>().add(UploadOcrAkhirEvent(file));
        },
      );
    }

    return BlocListener<KmbusBloc, KmbusState>(
      listenWhen: (prev, curr) =>
      prev.uploadStatus != curr.uploadStatus ||
          prev.submitStatus != curr.submitStatus ||
          prev.submitWorkflowStatus != curr.submitWorkflowStatus,
      listener: (context, state) async {
        if (state.uploadStatus == UploadStatus.errorOcr) {
          CoreSnackbar.show(
            context,
            message: "Speedometer gagal terdeteksi, coba kembali.",
            type: SnackbarType.failed,
          );
        }

        if (state.submitStatus == SubmitStatus.success) {
          await _showSubmitDraftModal(context, state.idAuditTrail);
          return;
        }

        if (state.submitStatus == SubmitStatus.failed) {
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal menyimpan data.",
            type: SnackbarType.failed,
          );
          return;
        }

        if (state.submitWorkflowStatus == SubmitWorkflowStatus.success) {
          CoreSnackbar.show(
            context,
            message: "Data berhasil disubmit.",
            type: SnackbarType.success,
          );

          await Future.delayed(const Duration(seconds: 2));

          if (!context.mounted) return;
          context.pop();
          return;
        }

        if (state.submitWorkflowStatus == SubmitWorkflowStatus.failed) {
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal submit data.",
            type: SnackbarType.failed,
          );

          await Future.delayed(const Duration(seconds: 2));

          if (!context.mounted) return;
          context.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  CoreHeader(
                    title: 'Submit Titik Akhir',
                    customBgColor: Colors.white,
                    withBorder: true,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.03,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                          bottom: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<KmbusBloc, KmbusState>(
                            buildWhen: (prev, curr) =>
                            prev.ocrResult != curr.ocrResult,
                            builder: (context, state) {
                              if (state.ocrResult != null) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Odometer : ${state.ocrResult}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showEditOdometerDialog(
                                        context,
                                        state.ocrResult,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.blue,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.edit_note,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Foto Speedometer",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          BlocBuilder<KmbusBloc, KmbusState>(
                            buildWhen: (prev, curr) =>
                            prev.titikAkhirCreate?.document !=
                                curr.titikAkhirCreate?.document ||
                                prev.documentUploadStatus !=
                                    curr.documentUploadStatus,
                            builder: (context, state) {
                              final doc = state.documentPreview.firstOrNull;

                              return CoreCameraWidget(
                                title: "Ambil Foto Speedometer",
                                imageUrl: doc?.url,
                                isLoading:
                                state.documentUploadStatus ==
                                    DocumentUploadStatus.uploading,
                                onTap: () {
                                  if (doc != null) {
                                    CoreCameraWidget.showPreviewDialog(
                                      context: context,
                                      imageUrl: doc.url,
                                      onDelete: () {
                                        context.read<KmbusBloc>().add(
                                          RemoveDocumentById(doc.idDocument),
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  } else if (state.documentUploadStatus !=
                                      DocumentUploadStatus.uploading) {
                                    _openCamera();
                                  }
                                },
                                onRemoveImage: doc == null
                                    ? null
                                    : () {
                                  context.read<KmbusBloc>().add(
                                    RemoveDocumentById(doc.idDocument),
                                  );
                                },
                                instructions: const [
                                  "Pastikan foto tidak buram",
                                  "Pastikan odometer yang didapatkan sesuai dengan yang di foto",
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<KmbusBloc, KmbusState>(
                    buildWhen: (prev, curr) =>
                    prev.ocrResult != curr.ocrResult ||
                        prev.titikAkhirCreate != curr.titikAkhirCreate ||
                        prev.status != curr.status ||
                        prev.submitStatus != curr.submitStatus ||
                        prev.submitWorkflowStatus != curr.submitWorkflowStatus,
                    builder: (context, state) {
                      final isLoading =
                          state.status == KmbusStatus.fetching ||
                              state.submitStatus == SubmitStatus.submitting ||
                              state.submitWorkflowStatus == SubmitWorkflowStatus.submitting;

                      final isSubmitable =
                          !isLoading &&
                              state.titikAkhirCreate?.titikAkhir != 0 &&
                              (state.titikAkhirCreate?.document.isNotEmpty ?? false);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20,
                        ),
                        child: CoreButton(
                          width: double.infinity,
                          onPressed: () {
                            if (!isSubmitable) return;
                            context.read<KmbusBloc>().add(SubmitTitikAkhir());
                          },
                          backgroundColor: isSubmitable
                              ? theme.colorScheme.primary
                              : Colors.grey,
                          child: Text(
                            "Submit",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              BlocBuilder<KmbusBloc, KmbusState>(
                buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                    prev.uploadStatus != curr.uploadStatus ||
                    prev.submitStatus != curr.submitStatus ||
                    prev.submitWorkflowStatus != curr.submitWorkflowStatus,
                builder: (context, state) {
                  final isLoading =
                      state.status == KmbusStatus.initial ||
                          state.status == KmbusStatus.fetching ||
                          state.uploadStatus == UploadStatus.uploading ||
                          state.submitStatus == SubmitStatus.submitting ||
                          state.submitWorkflowStatus == SubmitWorkflowStatus.submitting;

                  if (!isLoading) return const SizedBox.shrink();

                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(120),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}