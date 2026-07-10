import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/helper/camera_access_helper.dart';
import 'package:travis/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:travis/core/presentations/widgets/core_button.dart';
import 'package:travis/core/presentations/widgets/core_camera_widget.dart';
import 'package:travis/core/presentations/widgets/core_dropdown_search.dart';
import 'package:travis/core/presentations/widgets/core_header.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:travis/features/kmbus/presentation/bloc/kmbus_state.dart';
import 'package:travis/features/reference/domain/entities/reference_detail.dart';

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
    final state = context.read<KmbusBloc>().state;
    final controller = TextEditingController(
      text: ocrValue == "-" ? "" : ocrValue,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Validasi Odometer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.speedometerImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      state.speedometerImage!,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  "Cocokkan angka pada foto dengan input di bawah ini:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Odometer (KM)',
                    hintText: 'Masukkan angka odometer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                onRetake();
              },
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: Colors.blue,
              ),
              label: const Text(
                "Foto Ulang",
                style: TextStyle(color: Colors.blue),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final newValue = int.tryParse(controller.text);
                if (newValue != null) {
                  context.read<KmbusBloc>().add(EditOdometerAwal(newValue));
                  Navigator.pop(dialogContext);
                  CoreSnackbar.show(
                    context,
                    message: "Angka odometer disimpan.",
                    type: SnackbarType.success,
                  );
                } else {
                  CoreSnackbar.show(
                    dialogContext,
                    message: "Masukkan angka yang valid.",
                    type: SnackbarType.failed,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text("Simpan"),
            ),
          ],
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
                            // Card 1: Informasi Unit Bus
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
                                        Icons.directions_bus,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Informasi Unit Bus",
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
                                    builder: (context, state) {
                                      ReferenceDetail? selectedKoridor;
                                      if (state.referenceKoridor.isNotEmpty) {
                                        final matched = state.referenceKoridor
                                            .where(
                                              (e) => e.id == state.idKoridor,
                                            );
                                        if (matched.isNotEmpty) {
                                          selectedKoridor = matched.first;
                                        }
                                      }
                                      return CoreDropdownSearch<
                                        ReferenceDetail
                                      >(
                                        readOnly: true,
                                        label: 'Pilih Koridor',
                                        hintText: 'Pilih Koridor',
                                        popupTitle: 'Daftar Koridor',
                                        items: state.referenceKoridor,
                                        selectedItem: selectedKoridor,
                                        itemAsString: (item) =>
                                            '${item.code} - ${item.name}',
                                        compareFn: (a, b) => a.id == b.id,
                                        isRequired: true,
                                        isItemSelected: (item) =>
                                            item.id == state.idKoridor,
                                        onSelected: (value) {
                                          if (value == null) return;
                                          context.read<KmbusBloc>().add(
                                            SelectKoridor(value.id, value.name),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<KmbusBloc, KmbusState>(
                                    buildWhen: (prev, curr) =>
                                        prev.idKoridor != curr.idKoridor ||
                                        prev.referenceBus !=
                                            curr.referenceBus ||
                                        prev.idBus != curr.idBus ||
                                        prev.status != curr.status,
                                    builder: (context, state) {
                                      ReferenceDetail? selectedBus;
                                      if (state.referenceBus.isNotEmpty) {
                                        final matched = state.referenceBus
                                            .where((e) => e.id == state.idBus);
                                        if (matched.isNotEmpty) {
                                          selectedBus = matched.first;
                                        }
                                      }
                                      if (state.referenceBus.isEmpty &&
                                          state.idKoridor != 0 &&
                                          state.status !=
                                              KmbusStatus.fetching) {
                                        return const Text(
                                          "Tidak terdapat bus terdata di koridor tersebut",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      }
                                      if (state.idKoridor == 0 ||
                                          state.referenceBus.isEmpty) {
                                        return const SizedBox(height: 0);
                                      }
                                      return CoreDropdownSearch<
                                        ReferenceDetail
                                      >(
                                        readOnly: true,
                                        label: 'Pilih Bus',
                                        hintText: 'Pilih Bus',
                                        popupTitle: 'Daftar Bus',
                                        items: state.referenceBus,
                                        selectedItem: selectedBus,
                                        itemAsString: (item) =>
                                            '${item.code} - ${item.name}',
                                        compareFn: (a, b) => a.id == b.id,
                                        isItemSelected: (item) =>
                                            item.id == state.idBus,
                                        isRequired: true,
                                        onSelected: (value) {
                                          if (value == null) return;
                                          context.read<KmbusBloc>().add(
                                            SelectBus(value.id, value.name),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Card 2: Validasi Odometer Terdeteksi (jika ada)
                            BlocBuilder<KmbusBloc, KmbusState>(
                              buildWhen: (prev, curr) =>
                                  prev.ocrResult != curr.ocrResult,
                              builder: (context, state) {
                                if (state.ocrResult == null) {
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
                                              "${state.ocrResult} KM",
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
                                            state.ocrResult,
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
