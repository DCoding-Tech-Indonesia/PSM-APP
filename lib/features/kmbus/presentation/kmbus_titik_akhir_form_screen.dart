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
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';

import 'bloc/kmbus_event.dart';

class KmbusTitikAkhirFormScreen extends StatefulWidget {
  const KmbusTitikAkhirFormScreen({
    super.key,
    required this.idKm,
    this.idAuditTrail,
  });

  final int idKm;
  final int? idAuditTrail;

  @override
  State<KmbusTitikAkhirFormScreen> createState() =>
      _KmbusTitikAkhirFormScreenState();
}

class _KmbusTitikAkhirFormScreenState extends State<KmbusTitikAkhirFormScreen> {
  UploadStatus? _lastHandledUploadStatus;
  SubmitStatus? _lastHandledSubmitStatus;
  SubmitWorkflowStatus? _lastHandledSubmitWorkflowStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<KmbusBloc>().add(
        KmbusTitikAkhirInputLoad(widget.idKm, widget.idAuditTrail),
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
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<KmbusBloc>().add(SubmitWorkflow("Done", id));
    } else {
      context.pop(true);
    }
  }

  void _showOcrValidationDialog(
    BuildContext context,
    String ocrValue,
    VoidCallback onRetake,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CoreBlurDialog(
          title: "Validasi Odometer",
          message:
              "Hasil pemindaian speedometer: $ocrValue KM.\nApakah angka ini sudah sesuai dengan speedometer fisik?",
          badgeColor: Colors.blue,
          badgeText: 'KONFIRMASI',
          badgeIcon: Icons.camera_alt_outlined,
          buttonColor: Colors.blue[600]!,
          confirmText: "Ya, Benar",
          onConfirm: () {
            CoreSnackbar.show(
              context,
              message: "Angka odometer dikonfirmasi.",
              type: SnackbarType.success,
            );
          },
          contentWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showEditOdometerDialog(context, ocrValue);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Ubah Manual",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    onRetake();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Foto Ulang",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

    Future<void> openCamera() async {
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
          prev.submitWorkflowStatus != curr.submitWorkflowStatus ||
          prev.idAuditTrail != curr.idAuditTrail,
      listener: (context, state) async {
        if (state.uploadStatus == UploadStatus.errorOcr &&
            _lastHandledUploadStatus != state.uploadStatus) {
          _lastHandledUploadStatus = state.uploadStatus;
          CoreSnackbar.show(
            context,
            message: "Speedometer gagal terdeteksi, coba kembali.",
            type: SnackbarType.failed,
          );
          return;
        }

        if (state.uploadStatus == UploadStatus.successDocs &&
            _lastHandledUploadStatus != state.uploadStatus) {
          _lastHandledUploadStatus = state.uploadStatus;
          _showOcrValidationDialog(context, state.ocrResult ?? '-', openCamera);
        }

        if (state.submitStatus == SubmitStatus.success &&
            _lastHandledSubmitStatus != state.submitStatus) {
          _lastHandledSubmitStatus = state.submitStatus;
          await _showSubmitDraftModal(context, state.idAuditTrail);
          return;
        }

        if (state.submitStatus == SubmitStatus.failed &&
            _lastHandledSubmitStatus != state.submitStatus) {
          _lastHandledSubmitStatus = state.submitStatus;
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal menyimpan data.",
            type: SnackbarType.failed,
          );
          return;
        }

        if (state.submitWorkflowStatus == SubmitWorkflowStatus.success &&
            _lastHandledSubmitWorkflowStatus != state.submitWorkflowStatus) {
          _lastHandledSubmitWorkflowStatus = state.submitWorkflowStatus;
          CoreSnackbar.show(
            context,
            message: "Data berhasil disubmit.",
            type: SnackbarType.success,
          );

          await Future.delayed(const Duration(seconds: 2));

          if (!context.mounted) return;
          context.pop(true);
          return;
        }

        if (state.submitWorkflowStatus == SubmitWorkflowStatus.failed &&
            _lastHandledSubmitWorkflowStatus != state.submitWorkflowStatus) {
          _lastHandledSubmitWorkflowStatus = state.submitWorkflowStatus;
          CoreSnackbar.show(
            context,
            message: state.message ?? "Gagal submit data.",
            type: SnackbarType.failed,
          );

          await Future.delayed(const Duration(seconds: 2));

          if (!context.mounted) return;
          context.pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
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
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          BlocBuilder<KmbusBloc, KmbusState>(
                            buildWhen: (prev, curr) =>
                                prev.ocrResult != curr.ocrResult,
                            builder: (context, state) {
                              if (state.ocrResult != null) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                prev.documentPreview != curr.documentPreview ||
                                prev.documentUploadStatus !=
                                    curr.documentUploadStatus,
                            builder: (context, state) {
                              final localDoc =
                                  state.documentPreview.firstOrNull;
                              final apiDoc =
                                  state.titikAkhirCreate?.document.firstOrNull;

                              final imageUrl = localDoc?.url ?? apiDoc?.urlDoc;
                              final hasImage =
                                  imageUrl != null && imageUrl.isNotEmpty;

                              final targetIdDocument =
                                  localDoc?.idDocument ??
                                  apiDoc?.idDocument ??
                                  0;

                              return CoreCameraWidget(
                                title: "Ambil Foto Speedometer",
                                imageUrl: imageUrl,
                                isLoading:
                                    state.documentUploadStatus ==
                                    DocumentUploadStatus.uploading,
                                onTap: () {
                                  if (hasImage) {
                                    CoreCameraWidget.showPreviewDialog(
                                      context: context,
                                      imageUrl: imageUrl,
                                      onDelete: () {
                                        context.read<KmbusBloc>().add(
                                          RemoveDocumentById(targetIdDocument),
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  } else if (state.documentUploadStatus !=
                                      DocumentUploadStatus.uploading) {
                                    openCamera();
                                  }
                                },
                                onRemoveImage: !hasImage
                                    ? null
                                    : () {
                                        context.read<KmbusBloc>().add(
                                          RemoveDocumentById(targetIdDocument),
                                        );
                                      },
                                instructions: const [
                                  "Pastikan foto tidak buram",
                                  "Pastikan odometer yang didapatkan sesuai dengan yang di foto",
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
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
                          state.submitWorkflowStatus ==
                              SubmitWorkflowStatus.submitting;

                      final isSubmitable =
                          !isLoading &&
                          state.titikAkhirCreate?.titikAkhir != 0 &&
                          (state.titikAkhirCreate?.document.isNotEmpty ??
                              false);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20,
                        ),
                        child: CoreButton(
                          width: double.infinity,
                          onPressed: () {
                            if (!isSubmitable) return;
                            context.read<KmbusBloc>().add(
                              SubmitTitikAkhir(
                                widget.idKm,
                                widget.idAuditTrail,
                              ),
                            );
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
          ),
        ),
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
                      state.submitWorkflowStatus ==
                          SubmitWorkflowStatus.submitting;

                  if (!isLoading) return const SizedBox.shrink();

                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(120),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
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
