import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class InitLoadingScreen extends StatefulWidget {
  const InitLoadingScreen({super.key, required this.menuName, this.menuDesc});

  final String menuName;
  final String? menuDesc;

  @override
  State<InitLoadingScreen> createState() => _InitLoadingScreenState();
}

class _InitLoadingScreenState extends State<InitLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller untuk animasi zoom in / zoom out
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Membuat efek membesar dan mengecil (skala 0.95 ke 1.05)
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Jalankan animasi bolak-balik secara terus-menerus
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                child: Lottie.asset(
                  'assets/lottie/bus.json',
                  animate: true,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 24),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Memuat Halaman",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.menuName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (widget.menuDesc != null)
                      Text(
                        widget.menuDesc!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          color: Color(0xFF64748B),
                          letterSpacing: -0.1,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}