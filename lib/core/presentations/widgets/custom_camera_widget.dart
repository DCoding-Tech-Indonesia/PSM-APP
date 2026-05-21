import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

import 'core_bottom_modal_alert.dart';

class CustomCameraWidget extends StatefulWidget {
  final double ratio;

  const CustomCameraWidget({super.key, this.ratio = 1});

  @override
  State<CustomCameraWidget> createState() => _CustomCameraWidgetState();
}

class _CustomCameraWidgetState extends State<CustomCameraWidget> {
  CameraController? _controller;

  List<CameraDescription>? cameras;

  bool _isCapturing = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(
      cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<File> _cropToRatio(File file) async {
    final bytes = await file.readAsBytes();

    final original = img.decodeImage(bytes)!;

    final w = original.width;
    final h = original.height;

    final targetRatio = widget.ratio;

    int cropW = w;
    int cropH = (cropW / targetRatio).round();

    if (cropH > h) {
      cropH = h;
      cropW = (cropH * targetRatio).round();
    }

    final offsetX = ((w - cropW) / 2).round();
    final offsetY = ((h - cropH) / 2).round();

    final cropped = img.copyCrop(
      original,
      x: offsetX,
      y: offsetY,
      width: cropW,
      height: cropH,
    );

    final dir = await getTemporaryDirectory();

    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newFile = File(path);

    await newFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));

    return newFile;
  }

  Future<void> takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final image = await _controller!.takePicture();

      final file = File(image.path);

      final cropped = await _cropToRatio(file);

      if (!mounted) return;

      _showPreviewModal(cropped);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _showPreviewModal(File imageFile) {
    final parentContext = this.context;
    final settlementBlocContext = context.read<SettlementBloc>();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Preview Foto",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: widget.ratio,
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              _isUploading = true;
                            });

                            final bloc = settlementBlocContext;

                            bloc.add(UploadDocument(imageFile));

                            final resultState = await bloc.stream.firstWhere((
                              state,
                            ) {
                              return state.status ==
                                      SettlementStatus.failedSave ||
                                  state.status == SettlementStatus.success;
                            });

                            if (!mounted) return;

                            Navigator.pop(context);

                            if (resultState.status ==
                                SettlementStatus.failedSave) {
                              showModalBottomSheet(
                                context: context,
                                enableDrag: false,
                                builder: (_) => const CoreBottomModalAlert(
                                  success: false,
                                  message: "Gagal menyimpan foto",
                                ),
                              );

                              return;
                            }

                            final uploadedDocument = resultState.document.last;

                            final previewContext = context;

                            Navigator.pop(previewContext);

                            showModalBottomSheet(
                              context: parentContext,
                              enableDrag: false,
                              builder: (_) => const CoreBottomModalAlert(
                                success: true,
                                message: "Foto berhasil disimpan",
                              ),
                            );

                            await Future.delayed(
                              const Duration(seconds: 2),
                            );

                            if (!mounted) return;

                            Navigator.of(
                              parentContext,
                              rootNavigator: true,
                            ).pop();

                            parentContext.pop();
                          } catch (e) {
                            debugPrint(e.toString());
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isUploading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ambil Gambar")),
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          Center(
            child: AspectRatio(
              aspectRatio: widget.ratio,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isCapturing ? Colors.grey : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
