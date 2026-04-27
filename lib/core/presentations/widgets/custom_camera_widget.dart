import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CustomCameraWidget extends StatefulWidget {
  final double ratio;

  const CustomCameraWidget({
    super.key,
    this.ratio = 1,
  });

  @override
  State<CustomCameraWidget> createState() => _CustomCameraWidgetState();
}

class _CustomCameraWidgetState extends State<CustomCameraWidget> {
  CameraController? _controller;
  List<CameraDescription>? cameras;

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

    if (mounted) setState(() {});
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
    final path =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newFile = File(path);
    await newFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));

    return newFile;
  }

  Future<void> takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final file = File(image.path);

    final cropped = await _cropToRatio(file);

    context.pop(cropped);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Ambil Gambar"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: AspectRatio(
              aspectRatio: widget.ratio,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
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
                onTap: takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}