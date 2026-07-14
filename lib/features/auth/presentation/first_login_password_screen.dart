import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/presentations/widgets/core_input_field_new.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';

class FirstLoginPasswordScreen extends StatefulWidget {
  final String oldPassword;
  const FirstLoginPasswordScreen({super.key, required this.oldPassword});

  @override
  State<FirstLoginPasswordScreen> createState() =>
      _FirstLoginPasswordScreenState();
}

class _FirstLoginPasswordScreenState extends State<FirstLoginPasswordScreen> {
  bool _isLoading = false;
  String _newPassword = '';
  String _confirmPassword = '';

  Future<void> _submitPassword() async {
    final newPassword = _newPassword;
    final confirmPassword = _confirmPassword;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError("Password tidak boleh kosong");
      return;
    }

    if (newPassword != confirmPassword) {
      _showError("Password tidak cocok");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dio = DioClient().instance;
      final secureStorage = SecureStorageService();

      final userIdStr = await secureStorage.readUserId();
      final userId = int.tryParse(userIdStr ?? '0') ?? 0;

      final response = await dio.post(
        '/auth/first-login/change-password',
        data: {
          'idUser': userId,
          'passwordOld': widget.oldPassword,
          'passwordNew': newPassword,
          'passwordConfirm': confirmPassword,
        },
      );

      final status = response.data['status'] as bool?;
      if (status == true) {
        // Hapus flag firstLogin agar tidak diarahkan ke sini lagi
        await SecureStorageService().clearFirstLogin();
        // Hapus password lama yang tersimpan untuk keamanan
        await SecureStorageService().clearPassCred();
        if (mounted) {
          CoreSnackbar.show(
            context,
            message: "Password berhasil diatur",
            type: SnackbarType.success,
          );
          if (mounted) {
            context.go('/portal');
          }
        }
      } else {
        final message = response.data['message'] ?? 'Gagal mengatur password';
        _showError(message.toString());
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Terjadi kesalahan jaringan';
      _showError(message.toString());
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      CoreSnackbar.show(context, message: message, type: SnackbarType.failed);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Pengguna Baru",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 30,
                              offset: Offset(0, -10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(45),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat Datang!",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Buat Password Baru",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Demi keamanan, harap atur password baru untuk akun Anda sebelum melanjutkan.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                CoreInputFieldNew(
                                  label: "Password Baru",
                                  hintText: "********",
                                  isRequired: true,
                                  isSecured: true,
                                  rule: InputRuleSuffixNew.text,
                                  onChanged: (val) => _newPassword = val,
                                ),
                                const SizedBox(height: 16),
                                CoreInputFieldNew(
                                  label: "Konfirmasi Password",
                                  hintText: "********",
                                  isRequired: true,
                                  isSecured: true,
                                  rule: InputRuleSuffixNew.text,
                                  onChanged: (val) => _confirmPassword = val,
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _submitPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E3C72),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Simpan & Lanjutkan",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
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
    );
  }
}
