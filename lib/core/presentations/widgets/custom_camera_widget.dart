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

    if (mounted) {
      setState(() {});
    }
  }

  Future<File> _cropToRatio(File file) async {

    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes)!;

    int width = original.width;
    int height = original.height;

    double targetRatio = widget.ratio;

    int newWidth = width;
    int newHeight = (width / targetRatio).round();

    if (newHeight > height) {
      newHeight = height;
      newWidth = (height * targetRatio).round();
    }

    int offsetX = ((width - newWidth) / 2).round();
    int offsetY = ((height - newHeight) / 2).round();

    final cropped = img.copyCrop(
      original,
      x: offsetX,
      y: offsetY,
      width: newWidth,
      height: newHeight,
    );

    final dir = await getTemporaryDirectory();
    final croppedFile = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await croppedFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));

    return croppedFile;
  }

  Future<void> takePicture() async {

    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final file = File(image.path);

    final croppedFile = await _cropToRatio(file);

    context.pop(croppedFile);
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

          Center(
            child: AspectRatio(
              aspectRatio: widget.ratio,
              child: CameraPreview(_controller!),
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