import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/presentations/widgets/core_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _handleSubmit() async {
    final username = _emailController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      _showError("Email tidak boleh kosong");
      return;
    }

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
      final response = await dio.post(
        '/auth/forgot-password/reset',
        data: {
          'email': username,
          'newPassword': newPassword,
          'confirmNewPassword': confirmPassword,
        },
      );

      final status = response.data['status'] as bool?;
      if (status == true) {
        final dataList = response.data['data'] as List?;
        if (dataList != null && dataList.isNotEmpty) {
          final info = dataList[0];
          final nomorAdmin = info['nomorAdmin']?.toString() ?? '';
          final messageWa =
              info['messageWa']?.toString().replaceAll(r'\n', '\n') ??
              'Halo Admin, saya ingin melakukan pembaruan akun.';

          final whatsappUrl =
              "https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(messageWa)}";

          if (Platform.isIOS) {
            if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
              await canLaunchUrl(Uri.parse(whatsappUrl));

              if (mounted) {
                CoreSnackbar.show(
                  context,
                  message:
                      response.data['message'] ??
                      "Silakan hubungi admin untuk approval password yang baru",
                  type: SnackbarType.success,
                );

                await Future.delayed(const Duration(seconds: 2)).then((_) {
                  if (mounted) {
                    context.go('/login');
                  }
                });
              }
            } else {
              _showError("Whatsapp tidak terinstall");
            }
          } else {
            if (await launchUrl(Uri.parse(whatsappUrl))) {
              await launchUrl(
                Uri.parse(whatsappUrl),
                mode: LaunchMode.externalApplication,
              );

              if (mounted) {
                CoreSnackbar.show(
                  context,
                  message:
                      response.data['message'] ??
                      "Silakan hubungi admin untuk approval password yang baru",
                  type: SnackbarType.success,
                );

                await Future.delayed(const Duration(seconds: 2)).then((_) {
                  if (mounted) {
                    context.go('/login');
                  }
                });
              }
            } else {
              _showError("Whatsapp tidak terinstall");
            }
          }
        } else {
          _showError(response.data['message'] ?? "Data admin tidak ditemukan");
        }
      } else {
        _showError(
          response.data['message'] ?? "Email tidak terdaftar di sistem.",
        );
      }
    } catch (e) {
      _showError("Terjadi kesalahan: ${e.toString()}");
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
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.go('/login');
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Lupa Password",
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
                                "Reset Password",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Atur Password Baru",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Masukkan password baru yang Anda inginkan, lalu hubungi admin melalui WhatsApp untuk konfirmasi reset password.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                icon: Icons.email,
                                obscureText: false,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _newPasswordController,
                                label: "Password Baru",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: "Konfirmasi Password Baru",
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: _buildSubmitButton(
                                  text: "Hubungi Admin",
                                  onPressed: _handleSubmit,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "Admin akan membantu reset password Anda",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
