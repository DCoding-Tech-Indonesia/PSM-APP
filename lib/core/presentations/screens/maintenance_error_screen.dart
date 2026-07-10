import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/presentations/widgets/core_button.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/core/config/app_config.dart';
import 'package:dio/dio.dart';

class MaintenanceErrorScreen extends StatefulWidget {
  final String? errorMessage;
  final int? statusCode;

  const MaintenanceErrorScreen({
    super.key,
    this.errorMessage,
    this.statusCode,
  });

  @override
  State<MaintenanceErrorScreen> createState() => _MaintenanceErrorScreenState();
}

class _MaintenanceErrorScreenState extends State<MaintenanceErrorScreen> {
  bool _isChecking = false;

  Future<void> _checkTokenAndRefresh() async {
    setState(() => _isChecking = true);

    try {
      final secureStorage = SecureStorageService();
      final accessToken = await secureStorage.readAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        if (mounted) {
          CoreSnackbar.show(
            context,
            message: "Token tidak ditemukan, silakan login kembali",
            type: SnackbarType.failed,
          );
        }
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final response = await dio.get('/auth/check-token').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Token check timeout'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          CoreSnackbar.show(
            context,
            message: "Token valid, melanjutkan ke dashboard...",
            type: SnackbarType.success,
          );

          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            context.go('/dashboard');
          }
        }
      } else {
        if (mounted) {
          CoreSnackbar.show(
            context,
            message: "Token tidak valid, silakan login kembali",
            type: SnackbarType.failed,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CoreSnackbar.show(
          context,
          message: "Gagal memeriksa token: ${e.toString()}",
          type: SnackbarType.failed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusCode = widget.statusCode ?? 500;
    final isServerError = statusCode >= 500 && statusCode < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height - 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 60,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Error Title
                Text(
                  isServerError ? 'Layanan Sedang Maintenance' : 'Terjadi Kesalahan',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Error Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    isServerError
                        ? 'Kami sedang melakukan perbaikan sistem. Silakan coba lagi dalam beberapa saat.'
                        : 'Terjadi kesalahan saat menghubungi server. Silakan periksa koneksi Anda atau coba lagi nanti.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),

                // Status Code
                Text(
                  'Error Code: $statusCode',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),

                // Refresh Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: CoreButton(
                    width: double.infinity,
                    onPressed: _isChecking ? null : _checkTokenAndRefresh,
                    backgroundColor: _isChecking
                        ? Colors.grey
                        : theme.colorScheme.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isChecking)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade600,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.refresh_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isChecking ? 'Memeriksa...' : 'Coba Lagi',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to Login Button
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
