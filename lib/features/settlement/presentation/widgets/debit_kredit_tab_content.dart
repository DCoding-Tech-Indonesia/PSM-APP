import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/camera_access_helper.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class DebitKreditTabContent extends StatefulWidget {
  const DebitKreditTabContent({super.key});

  @override
  State<DebitKreditTabContent> createState() => _DebitKreditTabContentState();
}

class _DebitKreditTabContentState extends State<DebitKreditTabContent> {

  File? _image;

  Future<void> _openCamera() async {
    CameraAccessHelper.checkPermissions(
      context,
      onGranted: () async {

        final result = await context.push<File?>(
          '/camera',
          extra: 3 / 4,
        );

        if (result != null) {

          setState(() {
            _image = result;
          });

          context.read<SettlementBloc>().add(
            DebitKreditPictChanged(result),
          );
        }
      },
    );
  }

  void _deleteImage() {

    setState(() {
      _image = null;
    });

    context.read<SettlementBloc>().add(
      DebitKreditPictChanged(null),
    );
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

              InteractiveViewer(
                child: Image.file(_image!),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close,color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              )

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
    _image = state.debitKreditPict;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                onTap: _image == null ? _openCamera : _previewImage,
                child: _image == null
                    ? Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: .3),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_rounded),
                      SizedBox(height: 8),
                      Text("Ambiek Poto E"),
                    ],
                  ),
                )
                    : Stack(
                  children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _deleteImage,
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 26,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 12),

              const Text("Transaksi Debit / Kredit"),

            ],
          ),
        ],
      ),
    );
  }
}