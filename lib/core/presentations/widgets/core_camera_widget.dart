import 'package:flutter/material.dart';

class CoreCameraWidget extends StatelessWidget {
  const CoreCameraWidget({
    super.key,
    required this.onTap,
    required this.title,
    this.isLoading = false,
    this.height = 200,
    this.instructions = const [],
    this.imageUrl,
    this.onRemoveImage,
  });

  final VoidCallback onTap;
  final String title;
  final bool isLoading;
  final double height;
  final List<String> instructions;
  final String? imageUrl;
  final VoidCallback? onRemoveImage;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: _buildContent(context),
          ),
        ),

        if (instructions.isNotEmpty) ...[
          const SizedBox(height: 18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: instructions.map((instruction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 8, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        instruction,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    // Uploading
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            "Mengunggah & Memproses Gambar...",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    // Has Image
    if (hasImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, _, _) {
                return const Center(
                  child: Icon(Icons.broken_image_outlined, size: 48),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          if (onRemoveImage != null)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: onRemoveImage,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
        ],
      );
    }

    // Empty State
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  static Future<void> showPreviewDialog({
    required BuildContext context,
    required String imageUrl,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  if (onDelete != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Hapus"),
                      ),
                    ),

                  if (onDelete != null) const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Tutup"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
