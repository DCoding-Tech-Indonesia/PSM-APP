import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_camera_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_dropdown_search.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_state.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';

import 'bloc/kmbus_event.dart';

class KmbusTitikAwalFormScreen extends StatefulWidget {
  const KmbusTitikAwalFormScreen({super.key});

  @override
  State<KmbusTitikAwalFormScreen> createState() =>
      _KmbusTitikAwalFormScreenState();
}

class _KmbusTitikAwalFormScreenState extends State<KmbusTitikAwalFormScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<KmbusBloc>().add(KmbusTitikAwalInputLoad());
    });
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

          context.read<KmbusBloc>().add(UploadOcrEvent(file));
        },
      );
    }

    return BlocListener<KmbusBloc, KmbusState>(
      listenWhen: (prev, curr) => prev.uploadStatus != curr.uploadStatus,
      listener: (context, state) {
        if (state.uploadStatus == UploadStatus.errorOcr) {
          CoreSnackbar.show(
            context,
            message: "Speedometer gagal terdeteksi, coba kembali.",
            type: SnackbarType.failed,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CoreHeader(
                title: 'Submit Titik Awal',
                customBgColor: Colors.white,
                withBorder: true,
              ),
              Expanded(
                child: Container(
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
                      BlocBuilder<KmbusBloc, KmbusState>(
                        builder: (context, state) {
                          ReferenceDetail? selectedKoridor;

                          if (state.referenceKoridor.isNotEmpty) {
                            final matched = state.referenceKoridor.where(
                              (e) => e.id == state.idKoridor,
                            );
                            if (matched.isNotEmpty)
                              selectedKoridor = matched.first;
                          }

                          return CoreDropdownSearch<ReferenceDetail>(
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
                            prev.referenceBus != curr.referenceBus,
                        builder: (context, state) {
                          ReferenceBus? selectedBus;

                          if (state.referenceBus.isNotEmpty) {
                            final matched = state.referenceBus.where(
                              (e) => e.id == state.idBus,
                            );
                            if (matched.isNotEmpty) selectedBus = matched.first;
                          }

                          if (state.referenceBus.isEmpty &&
                              state.idKoridor != 0 &&
                              state.status != KmbusStatus.fetching) {
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
                            return SizedBox(height: 0);
                          }

                          return CoreDropdownSearch<ReferenceBus>(
                            label: 'Pilih Bus',
                            hintText: 'Pilih Bus',
                            popupTitle: 'Daftar Bus',
                            items: state.referenceBus,
                            selectedItem: selectedBus,
                            itemAsString: (item) =>
                                '${item.nomorLambung} - ${item.platNomor}',
                            compareFn: (a, b) => a.id == b.id,
                            isItemSelected: (item) => item.id == state.idBus,
                            isRequired: true,
                            onSelected: (value) {
                              if (value == null) return;
                              context.read<KmbusBloc>().add(
                                SelectBus(value.id, value.platNomor),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 12),

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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.blue,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.edit_note,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizedBox();
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
                        builder: (context, state) {
                          return CoreCameraWidget(
                            onTap: _openCamera,
                            title: "Ambil Foto Speedometer",
                            isLoading:
                                state.uploadStatus == UploadStatus.uploading,
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
                    prev.uploadStatus != curr.uploadStatus ||
                    prev.status != curr.status,
                builder: (context, state) {
                  final isLoading =
                      state.status == KmbusStatus.fetching ||
                      state.uploadStatus == UploadStatus.uploading;

                  final isSubmitable =
                      !isLoading && state.idKoridor != 0 && state.idBus != 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20,
                    ),
                    child: CoreButton(
                      width: double.infinity,
                      onPressed: () {
                        if (!isSubmitable) return;
                      },
                      backgroundColor: isSubmitable
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      child: Text(
                        "Submit",
                        style: TextStyle(
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
    );
  }
}
