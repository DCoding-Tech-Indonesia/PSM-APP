import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/config/app_config.dart';
import 'package:psm_mobile/core/helper/auth_token_helper.dart';
import 'package:psm_mobile/core/helper/jwt_helper.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import '../../../core/storage/onboarding_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigate based on onboarding status after animation
    _navigateBasedOnOnboarding();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateBasedOnOnboarding() async {
    // Tunggu animasi selesai
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final secureStorage = SecureStorageService();
    final dioClient = DioClient();
    final token = await secureStorage.readAccessToken();

    if (kDebugMode) {
      debugPrint(
        '[SPLASH] Token dari storage: ${token != null ? 'ADA' : 'KOSONG'}',
      );
      if (token != null) {
        debugPrint('[SPLASH] Status: ${JwtHelper.tokenStatus(token)}');
      }
    }

    // --- PRIORITAS 1: Cek apakah user sudah login ---
    if (token != null && token.isNotEmpty) {
      // Cek status token secara LOKAL tanpa internet
      if (JwtHelper.isExpired(token)) {
        // Token sudah mati total → tidak bisa ditolong, langsung ke login
        if (kDebugMode) {
          debugPrint('[SPLASH] Token EXPIRED → clearLogin → /login');
        }
        await secureStorage.clearLogin();
      } else if (JwtHelper.isExpiringSoon(token)) {
        // Token hampir mati (< 5 menit) → refresh dulu sebelum masuk portal
        if (kDebugMode) {
          debugPrint('[SPLASH] Token EXPIRING_SOON → coba refresh dulu...');
        }
        final refreshed = await _tryRefreshToken(secureStorage, dioClient);
        if (refreshed) {
          return; // _tryRefreshToken sudah handle navigate ke /portal
        }
        // Jika refresh gagal, lanjut ke login
      } else {
        // Token masih valid → verifikasi ke server sekali, lalu masuk portal
        if (kDebugMode) debugPrint('[SPLASH] Token VALID → hit check-token...');
        dioClient.setAuthToken(token);
        try {
          final response = await dioClient.instance.post('/auth/check-token');
          if (response.statusCode == 200 && response.data['status'] == true) {
            // Ambil token baru dari response (jika ada pembaruan dari server)
            final tokens = AuthTokenHelper.parseFromData(response.data['data']);
            String activeToken = tokens.accessToken ?? token;
            if (tokens.accessToken != null) {
              await AuthTokenHelper.saveTokens(
                secureStorage,
                accessToken: tokens.accessToken!,
                refreshToken: tokens.refreshToken,
              );
              dioClient.setAuthToken(activeToken);
            }
            // Jadwalkan refresh proaktif
            dioClient.scheduleProactiveRefresh(activeToken);
            await OnboardingStorage.markOnboardingShown('1.0.0');
            if (kDebugMode) debugPrint('[SPLASH] check-token OK → /portal');
            if (mounted) context.go('/portal');
            return;
          } else {
            // check-token gagal tapi token lokal masih valid → coba refresh dulu
            if (kDebugMode) {
              debugPrint(
                '[SPLASH] check-token status:false → coba refresh sebelum ke /login',
              );
            }
            final refreshed = await _tryRefreshToken(secureStorage, dioClient);
            if (refreshed) return;
            await secureStorage.clearLogin();
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[SPLASH] Exception check-token: $e → coba refresh...');
          }
          final refreshed = await _tryRefreshToken(secureStorage, dioClient);
          if (refreshed) return;
          await secureStorage.clearLogin();
        }
      }
    }

    // --- PRIORITAS 2: User belum/tidak login → cek onboarding ---
    if (!mounted) return;
    final shouldShowOnboarding = await OnboardingStorage.shouldShowOnboarding(
      '1.0.0',
    );
    if (shouldShowOnboarding) {
      await OnboardingStorage.markOnboardingShown('1.0.0');
    }
    if (kDebugMode) debugPrint('[SPLASH] → /login');
    if (mounted) context.go('/login');
  }

  /// Coba refresh token menggunakan refresh token yang tersimpan.
  /// Mengembalikan true jika berhasil (dan sudah navigate ke /portal).
  Future<bool> _tryRefreshToken(
    SecureStorageService secureStorage,
    DioClient dioClient,
  ) async {
    try {
      final storedRefreshToken = await secureStorage.readRefreshToken();
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        if (kDebugMode) debugPrint('[SPLASH] Refresh token kosong');
        return false;
      }

      // Decode refresh token: jika sudah expired, tidak perlu hit server
      if (JwtHelper.isExpired(storedRefreshToken)) {
        if (kDebugMode) {
          debugPrint('[SPLASH] Refresh token juga EXPIRED → /login');
        }
        await secureStorage.clearLogin();
        return false;
      }

      final tokenDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

      if (kDebugMode) debugPrint('[SPLASH] Hit /auth/refresh...');
      final response = await tokenDio.post(
        '/auth/refresh',
        queryParameters: {'refreshToken': storedRefreshToken},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final tokens = AuthTokenHelper.parseFromData(response.data['data']);

        if (tokens.accessToken != null) {
          await AuthTokenHelper.saveTokens(
            secureStorage,
            accessToken: tokens.accessToken!,
            refreshToken: tokens.refreshToken,
          );
          dioClient.setAuthToken(tokens.accessToken!);
          dioClient.scheduleProactiveRefresh(tokens.accessToken!);
          await OnboardingStorage.markOnboardingShown('1.0.0');
          if (kDebugMode) debugPrint('[SPLASH] Refresh OK → /portal');
          if (mounted) context.go('/portal');
          return true;
        }
      }

      if (kDebugMode) debugPrint('[SPLASH] Refresh gagal');
      await secureStorage.clearLogin();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[SPLASH] Exception refresh: $e');
      await secureStorage.clearLogin();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E3C72),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Text(
                              "PSM",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Padang",
                                style: TextStyle(
                                  color: Color(0xFF1E3C72),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "Sejahtera Mandiri.",
                                style: TextStyle(
                                  color: Color(0xFF1E3C72),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading Indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Memuat aplikasi...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
