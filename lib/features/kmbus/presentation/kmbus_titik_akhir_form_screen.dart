import 'dart:io';

import 'package:flutter/foundation.dart';
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

  Future<void> _showDifferentPointsConfirmation(
    BuildContext context,
    int titikAwal,
    int titikAkhir,
  ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: "Titik Awal dan Titik Akhir Berbeda",
          desc:
              "Titik awal: $titikAwal KM\nTitik akhir: $titikAkhir KM\n\nApakah data sudah sesuai?",
          cancelText: "Kembali",
          confirmText: "Lanjutkan",
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      if (!context.mounted) return;
      context.read<KmbusBloc>().add(
        SubmitTitikAkhir(widget.idKm, widget.idAuditTrail),
      );
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
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.speed_rounded,
                              color: Colors.red.shade700,
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
                                    color: Colors.red.shade700,
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
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cocokkan angka pada foto dengan input di bawah ini. Edit jika diperlukan.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
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
                                              EditOdometerAkhir(newValue),
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
                                                  Colors.red.shade700,
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
                                        : Colors.red.shade700,
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
            ElevatedButton.icon(
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
              icon: const Icon(Icons.check),
              label: const Text('Simpan'),
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
                    subtitle: 'Isian KM akhir perjalanan',
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
                            // Card: KM Entry Context (Titik Awal Info)
                            BlocBuilder<KmbusBloc, KmbusState>(
                              buildWhen: (prev, curr) =>
                                  prev.listKmbus != curr.listKmbus ||
                                  prev.titikAwalCreate != curr.titikAwalCreate ||
                                  prev.namaKoridor != curr.namaKoridor ||
                                  prev.noUnit != curr.noUnit,
                              builder: (context, state) {
                                // Debug logging untuk trace masalah
                                if (kDebugMode) {
                                  print('=== TITIK AKHIR DETAIL CARD DEBUG ===');
                                  print('widget.idKm: ${widget.idKm}');
                                  print('state.status: ${state.status}');
                                  print('state.listKmbus.length: ${state.listKmbus.length}');
                                  print('state.titikAwalCreate: ${state.titikAwalCreate}');
                                  print('state.namaKoridor: ${state.namaKoridor}');
                                  print('state.noUnit: ${state.noUnit}');
                                  if (state.listKmbus.isNotEmpty) {
                                    print('listKmbus IDs: ${state.listKmbus.map((e) => e.id).toList()}');
                                  }
                                }

                                // Prioritas 1: Gunakan data dari titikAwalCreate (untuk mode edit)
                                // Prioritas 2: Cari di listKmbus (untuk data dari API)
                                // Prioritas 3: Gunakan data dari state (namaKoridor, noUnit, dll)
                                final kmDataList = state.listKmbus
                                    .where((km) => km.id == widget.idKm)
                                    .toList();
                                final kmDataFromList = kmDataList.isNotEmpty
                                    ? kmDataList.first
                                    : null;

                                if (kDebugMode) {
                                  print('kmDataFromList found: ${kmDataFromList != null}');
                                  if (kmDataFromList != null) {
                                    print('kmDataFromList.id: ${kmDataFromList.id}');
                                    print('kmDataFromList.titikAwal: ${kmDataFromList.titikAwal}');
                                  }
                                }

                                // Jika masih loading (status initial dan list kosong), tampilkan loading
                                if (state.status == KmbusStatus.initial && 
                                    state.listKmbus.isEmpty && 
                                    state.titikAwalCreate == null) {
                                  if (kDebugMode) {
                                    print('Showing loading indicator');
                                  }
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Memuat data perjalanan...',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // Gunakan data dari berbagai sumber dengan fallback chain
                                final titikAwalValue = state.titikAwalCreate?.titikAwal ?? 
                                    kmDataFromList?.titikAwal ?? 0;
                                final tanggalKm = kmDataFromList?.tanggalKm ?? 
                                    DateTime.now().toString().split(' ')[0];
                                final koridorName = kmDataFromList?.koridor?.name ?? 
                                    state.namaKoridor ?? '-';
                                final busNumber = kmDataFromList?.bus?.nomorLambung ?? 
                                    state.noUnit ?? '-';

                                if (kDebugMode) {
                                  print('Display values:');
                                  print('- titikAwalValue: $titikAwalValue');
                                  print('- tanggalKm: $tanggalKm');
                                  print('- koridorName: $koridorName');
                                  print('- busNumber: $busNumber');
                                  print('Rendering card now...');
                                  print('======================================');
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Row 1: Titik Awal
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue.shade200,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Titik Awal Perjalanan',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(
                                                          0xFF718096,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '$titikAwalValue KM',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors
                                                            .blue
                                                            .shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.location_on,
                                                  color: Colors.blue.shade700,
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Row 2: Date, Koridor, Bus
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    tanggalKm,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 85,
                                                    child: Text(
                                                      koridorName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(
                                                          0xFF2D3748,
                                                        ),
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
                                                    'Unit Bus',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF718096),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  SizedBox(
                                                    width: 75,
                                                    child: Text(
                                                      busNumber,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(
                                                          0xFF2D3748,
                                                        ),
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
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // Card 2: Validasi Odometer Terdeteksi (hanya tampil setelah konfirmasi)
                            BlocBuilder<KmbusBloc, KmbusState>(
                              buildWhen: (prev, curr) =>
                                  prev.titikAkhirCreate?.titikAkhir !=
                                  curr.titikAkhirCreate?.titikAkhir,
                              builder: (context, state) {
                                // Hanya tampil jika odometer sudah dikonfirmasi (tersimpan di titikAkhirCreate)
                                if (state.titikAkhirCreate?.titikAkhir ==
                                        null ||
                                    state.titikAkhirCreate?.titikAkhir == 0) {
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
                                              "${state.titikAkhirCreate?.titikAkhir} KM",
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
                                            state.titikAkhirCreate?.titikAkhir
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

                            // Card 2: Bukti Foto Odometer
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
                                        prev.titikAkhirCreate?.document !=
                                            curr.titikAkhirCreate?.document ||
                                        prev.documentPreview !=
                                            curr.documentPreview ||
                                        prev.documentUploadStatus !=
                                            curr.documentUploadStatus,
                                    builder: (context, state) {
                                      final localDoc =
                                          state.documentPreview.firstOrNull;
                                      final apiDoc = state
                                          .titikAkhirCreate
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
                        prev.ocrResult != curr.ocrResult ||
                        prev.titikAkhirCreate != curr.titikAkhirCreate ||
                        prev.titikAwalCreate != curr.titikAwalCreate ||
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

                            final titikAwal =
                                state.titikAwalCreate?.titikAwal ?? 0;
                            final titikAkhir =
                                state.titikAkhirCreate?.titikAkhir ?? 0;

                            if (titikAwal != 0 &&
                                titikAkhir != 0 &&
                                titikAwal != titikAkhir) {
                              _showDifferentPointsConfirmation(
                                context,
                                titikAwal,
                                titikAkhir,
                              );
                            } else {
                              context.read<KmbusBloc>().add(
                                SubmitTitikAkhir(
                                  widget.idKm,
                                  widget.idAuditTrail,
                                ),
                              );
                            }
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
