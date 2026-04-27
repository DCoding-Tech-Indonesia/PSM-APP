import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_input_card.dart';

import 'package:psm_mobile/core/helper/camera_access_helper.dart';

class SettlementAddScreen extends StatefulWidget {
  const SettlementAddScreen({super.key});


  @override
  State<SettlementAddScreen> createState() => _SettlementAddScreenState();
}

class _SettlementAddScreenState extends State<SettlementAddScreen> {

  File? _image;

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
              /// IMAGE PREVIEW
              Flexible(
                child: Stack(
                  children: [
                    InteractiveViewer(
                      child: Image.file(_image!),
                    ),

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

              /// ACTION BUTTONS
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: CoreStyling.coreDeleteButtonGradient,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _image = null;
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: CoreStyling.coreActiveButtonGradient,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openCamera();
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: false,
        title: const Text("Submit Settlement"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFFFAFAFA)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    spacing: 18,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Text(
                      //     "Langkah 1 dari 2",
                      //     style: TextStyle(fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui Kartu",
                        method: "card",
                      ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui Brizzi",
                        method: "brizzi",
                      ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui QRIS",
                        method: "qris",
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                        ),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "Unggah Foto Bukti Settlement",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _image == null ? _openCamera : _previewImage,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: .5,
                                  ),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16/4,
                                  child: _image == null
                                      ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.camera_alt_rounded),
                                      SizedBox(height: 8),
                                      Text("Format: PNG/JPG, Max 2mb"),
                                    ],
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: CoreStyling.coreActiveButtonGradient,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "Simpan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
