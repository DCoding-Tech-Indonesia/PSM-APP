import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class SettlementSecondStep extends StatefulWidget {
  const SettlementSecondStep({super.key});

  @override
  State<SettlementSecondStep> createState() => _SettlementSecondStepState();
}

class _SettlementSecondStepState extends State<SettlementSecondStep> {
  File? _image;

  Future<void> _openCamera(double ratio) async {
    CameraAccessHelper.checkPermissions(
      context,
      onGranted: () async {
        final result = await context.push<File?>('/camera', extra: ratio);

        if (result != null) {
          setState(() {
            _image = result;
          });

          context.read<SettlementBloc>().add(SettlementPictChanged(result));
        }
      },
    );
  }

  void _deleteImage() {
    setState(() {
      _image = null;
    });

    context.read<SettlementBloc>().add(SettlementPictChanged(null));
  }

  void _previewImage() {
    if (_image == null) return;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
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
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    final state = context.read<SettlementBloc>().state;
    _image = state.settlementPict;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = 9 / 16;
    final theme = Theme.of(context);

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Lampiran Foto Bukti Settlement"),
        SizedBox(
          width: double.infinity,
          child: Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image == null
                  ? Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: .3),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded),
                          Text("Gambar Akan Ditampilkan Disini"),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: _previewImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Image.file(
                              _image!,
                              height: 400,
                              width: double.infinity,
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        ),
                      ),
                    ),
              GestureDetector(
                onTap: () => _openCamera(ratio),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Ambil Foto",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _image == null ? null : _deleteImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _image == null
                        ? theme.disabledColor
                        : theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Hapus Foto",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
