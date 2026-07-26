import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/helper/camera_access_helper.dart';
import 'package:travis/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:travis/core/presentations/widgets/core_button.dart';
import 'package:travis/core/presentations/widgets/core_camera_widget.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_state.dart';

import 'bloc/kmbus_event.dart';

class KmbusTitikAwalFormScreen extends StatefulWidget {
  const KmbusTitikAwalFormScreen({
    super.key,
    required this.idShift,
    required this.idKoridorShift,
    required this.idBusShift,
    this.idAuditTrail,
  });

  final int idShift;
  final int idKoridorShift;
  final int idBusShift;
  final int? idAuditTrail;

  @override
  State<KmbusTitikAwalFormScreen> createState() =>
      _KmbusTitikAwalFormScreenState();
}

class _KmbusTitikAwalFormScreenState extends State<KmbusTitikAwalFormScreen> {
  UploadStatus? _lastHandledUploadStatus;
  SubmitStatus? _lastHandledSubmitStatus;
  SubmitWorkflowStatus? _lastHandledSubmitWorkflowStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<KmbusBloc>().add(
        KmbusTitikAwalInputLoad(
          widget.idShift,
          widget.idKoridorShift,
          widget.idBusShift,
          widget.idAuditTrail,
        ),
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
      context.pop(true);
    }
  }

  void _showOcrValidationDialog(
    BuildContext context,
    String ocrValue,
    VoidCallback onRetake,
  ) {
    final bloc = context.read<KmbusBloc>();
    final state = bloc.state;
    final controller = TextEditingController(
      text: ocrValue == "-" ? "" : ocrValue,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider<KmbusBloc>.value(
          value: bloc,
          child: BlocListener<KmbusBloc, KmbusState>(
            listenWhen: (prev, curr) =>
                prev.documentUploadStatus != curr.documentUploadStatus,
            listener: (context, state) {
              // Close dialog after successful upload
              if (state.documentUploadStatus == DocumentUploadStatus.success &&
                  dialogContext.mounted) {
                Navigator.pop(dialogContext);
                CoreSnackbar.show(
                  context,
                  message: "Odometer disimpan.",
                  type: SnackbarType.success,
                );
              }

              // Show error if upload failed
              if (state.documentUploadStatus == DocumentUploadStatus.failed &&
                  dialogContext.mounted) {
                CoreSnackbar.show(
                  dialogContext,
                  message: state.message ?? "Gagal mengunggah dokumen.",
                  type: SnackbarType.failed,
                );
              }
            },
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.speed_rounded,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Validasi Odometer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Periksa kembali angka yang terdeteksi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      // Image Preview
                      if (state.speedometerImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            state.speedometerImage!,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cocokkan angka pada foto dengan input di bawah ini. Edit jika diperlukan.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Input Field
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        enabled:
                            state.documentUploadStatus !=
                            DocumentUploadStatus.uploading,
                        decoration: InputDecoration(
                          labelText: 'Nilai Odometer (KM)',
                          hintText: 'Masukkan angka odometer',
                          prefixIcon: Icon(
                            Icons.straighten,
                            color: Colors.grey.shade600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      BlocBuilder<KmbusBloc, KmbusState>(
                        buildWhen: (prev, curr) =>
                            prev.documentUploadStatus !=
                            curr.documentUploadStatus,
                        builder: (context, state) {
                          final isUploading =
                              state.documentUploadStatus ==
                              DocumentUploadStatus.uploading;

                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: isUploading
                                      ? null
                                      : () {
                                          Navigator.pop(dialogContext);
                                          context.read<KmbusBloc>().add(
                                            ResetUploadStatus(),
                                          );
                                          onRetake();
                                        },
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Foto Ulang",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: isUploading
                                          ? Colors.grey.shade200
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isUploading
                                      ? null
                                      : () {
                                          final newValue = int.tryParse(
                                            controller.text,
                                          );
                                          if (newValue != null) {
                                            context.read<KmbusBloc>().add(
                                              EditOdometerAwal(newValue),
                                            );
                                          } else {
                                            CoreSnackbar.show(
                                              dialogContext,
                                              message:
                                                  "Masukkan angka yang valid.",
                                              type: SnackbarType.failed,
                                            );
                                          }
                                        },
                                  icon: isUploading
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade700,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.check_circle,
                                          size: 18,
                                        ),
                                  label: Text(
                                    isUploading ? "Menyimpan..." : "Konfirmasi",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isUploading
                                        ? Colors.grey.shade300
                                        : Colors.blue.shade700,
                                    foregroundColor: isUploading
                                        ? Colors.grey.shade600
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                  context.read<KmbusBloc>().add(EditOdometerAwal(newValue));
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

          context.read<KmbusBloc>().add(UploadOcrAwalEvent(file));
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
        // Reset handler when upload goes idle (deleted/retaking photo)
        if (state.uploadStatus == UploadStatus.idling) {
          _lastHandledUploadStatus = null;
        }

        // Show loading while uploading
        if (state.uploadStatus == UploadStatus.uploading &&
            _lastHandledUploadStatus != state.uploadStatus) {
          _lastHandledUploadStatus = state.uploadStatus;
          CoreSnackbar.show(
            context,
            message: "Memproses gambar...",
            type: SnackbarType.warning,
          );
        }

        if (state.uploadStatus == UploadStatus.errorOcr &&
            _lastHandledUploadStatus != state.uploadStatus) {
          _lastHandledUploadStatus = state.uploadStatus;
          CoreSnackbar.show(
            context,
            message: "Speedometer gagal terdeteksi, coba kembali.",
            type: SnackbarType.failed,
          );
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
                    title: 'Submit Titik Awal',
                    subtitle: 'Isian KM awal perjalanan',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card: Entry Context Info
                            BlocBuilder<KmbusBloc, KmbusState>(
                              buildWhen: (prev, curr) =>
                                  prev.namaKoridor != curr.namaKoridor ||
                                  prev.noUnit != curr.noUnit ||
                                  prev.status != curr.status,
                              builder: (context, state) {
                                if (state.status == KmbusStatus.loading) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE8F5E9),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 120,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          height: 14,
                                          color: Color(0xFFF1F5F9),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  width: 80,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  width: 80,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  width: 60,
                                                  height: 14,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE8F5E9),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: Colors.green.shade700,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Detail Perjalanan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        height: 14,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tanggal',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF718096),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateTime.now().toString().split(
                                                  ' ',
                                                )[0],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF2D3748),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Koridor',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF718096),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  (state.namaKoridor ?? '')
                                                          .isNotEmpty
                                                      ? state.namaKoridor!
                                                      : '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bus',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF718096),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  (state.noUnit ?? '')
                                                          .isNotEmpty
                                                      ? state.noUnit!
                                                      : '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // Card 2: Validasi Odometer Terdeteksi (hanya tampil setelah konfirmasi)
                            BlocBuilder<KmbusBloc, KmbusState>(
                              buildWhen: (prev, curr) =>
                                  prev.titikAwalCreate?.titikAwal !=
                                  curr.titikAwalCreate?.titikAwal,
                              builder: (context, state) {
                                // Hanya tampil jika odometer sudah dikonfirmasi (tersimpan di titikAwalCreate)
                                if (state.titikAwalCreate?.titikAwal == null ||
                                    state.titikAwalCreate?.titikAwal == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.teal.shade500,
                                        Colors.teal.shade700,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.shade700.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.speed_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Odometer Terdeteksi",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${state.titikAwalCreate?.titikAwal} KM",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _showEditOdometerDialog(
                                            context,
                                            state.titikAwalCreate?.titikAwal
                                                .toString(),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: Colors.white30,
                                              ),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Card 3: Pengambilan Foto Speedometer
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue.shade50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade900.withValues(
                                      alpha: 0.03,
                                    ),
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
                                      Icon(
                                        Icons.camera_alt,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Bukti Foto Odometer",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(color: Color(0xFFF1F5F9)),
                                  ),
                                  BlocBuilder<KmbusBloc, KmbusState>(
                                    buildWhen: (prev, curr) =>
                                        prev.titikAwalCreate?.document !=
                                            curr.titikAwalCreate?.document ||
                                        prev.documentUploadStatus !=
                                            curr.documentUploadStatus,
                                    builder: (context, state) {
                                      final localDoc =
                                          state.documentPreview.firstOrNull;
                                      final apiDoc = state
                                          .titikAwalCreate
                                          ?.document
                                          .firstOrNull;
                                      final imageUrl =
                                          localDoc?.url ?? apiDoc?.urlDoc;
                                      final hasImage =
                                          imageUrl != null &&
                                          imageUrl.isNotEmpty;
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
                                                  RemoveDocumentById(
                                                    targetIdDocument,
                                                  ),
                                                );
                                                Navigator.pop(context);
                                              },
                                            );
                                          } else if (state
                                                  .documentUploadStatus !=
                                              DocumentUploadStatus.uploading) {
                                            openCamera();
                                          }
                                        },
                                        onRemoveImage: !hasImage
                                            ? null
                                            : () {
                                                context.read<KmbusBloc>().add(
                                                  RemoveDocumentById(
                                                    targetIdDocument,
                                                  ),
                                                );
                                              },
                                        instructions: const [
                                          "Pastikan foto tidak buram dan odometer terbaca jelas",
                                          "Sesuaikan angka odometer yang terbaca pada foto dengan isian",
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<KmbusBloc, KmbusState>(
                    buildWhen: (prev, curr) =>
                        prev.titikAwalCreate != curr.titikAwalCreate ||
                        prev.status != curr.status ||
                        prev.uploadStatus != curr.uploadStatus ||
                        prev.submitStatus != curr.submitStatus ||
                        prev.submitWorkflowStatus != curr.submitWorkflowStatus,
                    builder: (context, state) {
                      final isLoading =
                          state.status == KmbusStatus.fetching ||
                          state.uploadStatus == UploadStatus.uploading ||
                          state.submitStatus == SubmitStatus.submitting ||
                          state.submitWorkflowStatus ==
                              SubmitWorkflowStatus.submitting;

                      final isSubmitable =
                          !isLoading &&
                          state.titikAwalCreate?.titikAwal != 0 &&
                          (state.titikAwalCreate?.document.isNotEmpty ??
                              false) &&
                          state.titikAwalCreate?.idKoridor != 0 &&
                          state.titikAwalCreate?.idBus != 0;

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
                              SubmitTitikAwal(state.idAuditTrail),
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
            ],
          ),
        ),
      ),
    );
  }
}
