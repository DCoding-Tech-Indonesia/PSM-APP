import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
  bool _isCameraAvailable = true;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraAvailable = false;
          });
        }
        return;
      }

      _controller = CameraController(
        cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Gagal menginisialisasi kamera: $e');

      if (mounted) {
        setState(() {
          _isCameraAvailable = false;
        });
      }
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
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        final screenHeight = MediaQuery.of(modalContext).size.height;
        final screenWidth = MediaQuery.of(modalContext).size.width;
        final isPortrait = screenHeight > screenWidth;

        return SafeArea(
          child: Container(
            height: isPortrait ? screenHeight * 0.85 : screenHeight * 0.95,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isPortrait ? 20 : 12,
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Preview Foto",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPortrait ? 18 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(modalContext),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isPortrait ? 16 : 12),

                // Image Preview
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black54,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: widget.ratio,
                        child: Image.file(imageFile, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isPortrait ? 24 : 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(modalContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: EdgeInsets.symmetric(
                            vertical: isPortrait ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.close, size: 20),
                        label: Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: isPortrait ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(modalContext);
                          // Add delay to allow camera to gracefully shut down
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (parentContext.mounted) {
                            parentContext.pop<File>(imageFile);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isPortrait ? 14 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: isPortrait ? 14 : 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait = screenHeight > screenWidth;

    // Camera not available
    if (!_isCameraAvailable) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Ambil Gambar"),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.videocam_off,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kamera tidak tersedia",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Pastikan izin kamera diberikan atau aktifkan Virtual Camera pada simulator.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Kembali"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Camera initializing
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Ambil Gambar"),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Mempersiapkan Kamera",
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Camera ready
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Ambil Gambar"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(_controller!),

          // Semi-transparent overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),

          // Capture frame guide
          Center(
            child: AspectRatio(
              aspectRatio: widget.ratio,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 24 : 40,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // Corner indicators
          Positioned(
            top: isPortrait ? 100 : 50,
            left: 24,
            child: _buildCornerIndicator(),
          ),
          Positioned(
            top: isPortrait ? 100 : 50,
            right: 24,
            child: Transform.rotate(
              angle: 1.5708,
              child: _buildCornerIndicator(),
            ),
          ),
          Positioned(
            bottom: isPortrait ? 140 : 80,
            left: 24,
            child: Transform.rotate(
              angle: -1.5708,
              child: _buildCornerIndicator(),
            ),
          ),
          Positioned(
            bottom: isPortrait ? 140 : 80,
            right: 24,
            child: Transform.rotate(
              angle: 3.14159,
              child: _buildCornerIndicator(),
            ),
          ),

          // Bottom action area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isPortrait ? 32 : 20,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isCapturing)
                      Text(
                        "Posisikan perangkat sesuai batas putih",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: isPortrait ? 20 : 12),
                    Center(
                      child: GestureDetector(
                        onTap: _isCapturing ? null : takePicture,
                        child: Container(
                          width: isPortrait ? 90 : 80,
                          height: isPortrait ? 90 : 80,
                          decoration: BoxDecoration(
                            color: _isCapturing
                                ? Colors.grey.shade700
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: _isCapturing
                              ? Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.grey.shade300,
                                    ),
                                  ),
                                )
                              : null,
                        ),
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
  }

  Widget _buildCornerIndicator() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white, width: 3),
          left: BorderSide(color: Colors.white, width: 3),
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
      ),
    );
  }
}
