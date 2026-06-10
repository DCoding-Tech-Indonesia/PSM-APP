import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:psm_mobile/core/helper/version_ui_helper.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricTriggered = false;

  void _loginPressed(BuildContext context) {
    context.read<AuthBloc>().add(AuthSubmitted());
  }

  void _fingerprintLogin(BuildContext context) {
    context.read<AuthBloc>().add(BiometricSubmitted());
  }

  Future<void> handleFingerprint(BuildContext context) async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Scan sidik jari untuk masuk',
        biometricOnly: true,
      );

      if (authenticated) {
        _fingerprintLogin(context);
      } else {
        showModalBottomSheet(
          context: context,
          builder: (_) => const CoreBottomModalAlert(
            success: false,
            message: "Biometrik tidak dikenali",
          ),
        );
      }
    } on PlatformException catch (e) {
      if (kDebugMode) print(e);

      showModalBottomSheet(
        context: context,
        builder: (_) => const CoreBottomModalAlert(
          success: false,
          message: "Terjadi kesalahan biometrik",
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(LoadSavedCredentials());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (previous.pageLoaded != current.pageLoaded ||
          previous.popup != current.popup ||
          previous.allowBiometric != current.allowBiometric),
      listener: (context, state) {
        if (!_biometricTriggered && state.pageLoaded && state.allowBiometric) {
          _biometricTriggered = true;
          handleFingerprint(context);
        }

        if (!state.popup) return;

        final isSuccess = state.loginSuccess;

        CoreSnackbar.show(
          context,
          message: state.loginMessage,
          type: isSuccess
              ? SnackbarType.success
              : SnackbarType.failed,
        );

        context.read<AuthBloc>().add(ResetState());

        if (isSuccess) {
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.go('/portal');
            }
          });
        }
      },
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
                    const SizedBox(height: 50),
                    // Header Logo Area
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
                              color: Colors.white,
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
                                color: Color(0xFF1E3C72),
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
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                "Sejahtera Mandiri.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Login Card
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
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Selamat Datang,",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Aplikasi PSM Mobile.",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 35),

                                    // Input Fields
                                    BlocBuilder<AuthBloc, AuthState>(
                                      buildWhen: (prev, curr) =>
                                          prev.username != curr.username ||
                                          prev.usernameError !=
                                              curr.usernameError,
                                      builder: (context, state) {
                                        return CoreInputFieldNew(
                                          label: "Username",
                                          hintText: "Username",
                                          isRequired: true,
                                          rule: InputRuleSuffixNew.text,
                                          initValue: state.username,
                                          errorText:
                                              (state
                                                      .usernameError
                                                      ?.isNotEmpty ??
                                                  false)
                                              ? state.usernameError
                                              : null,
                                          onChanged: (value) => context
                                              .read<AuthBloc>()
                                              .add(UsernameChanged(value)),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    BlocBuilder<AuthBloc, AuthState>(
                                      buildWhen: (prev, curr) =>
                                          prev.password != curr.password ||
                                          prev.passwordError !=
                                              curr.passwordError,
                                      builder: (context, state) {
                                        return CoreInputFieldNew(
                                          label: "Password",
                                          hintText: "********",
                                          isRequired: true,
                                          isSecured: true,
                                          rule: InputRuleSuffixNew.text,
                                          initValue: state.password.value,
                                          errorText:
                                              (state
                                                      .passwordError
                                                      ?.isNotEmpty ??
                                                  false)
                                              ? state.passwordError
                                              : null,
                                          onChanged: (value) => context
                                              .read<AuthBloc>()
                                              .add(PasswordChanged(value)),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 15),

                                    // Action Row (Remember Me & Forgot Password)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            return CoreCheckbox(
                                              value: state.rememberMe,
                                              label: "Ingat Saya",
                                              activeColor: const Color(
                                                0xFF1E3C72,
                                              ),
                                              labelStyle: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                              onChanged: (value) {
                                                context.read<AuthBloc>().add(
                                                  RememberMeToggled(
                                                    value ?? false,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            "Lupa password?",
                                            style: TextStyle(
                                              color: Color(0xFF1E3C72),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Buttons
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: CoreButton(
                                                text: "Masuk",
                                                onPressed: () =>
                                                    _loginPressed(context),
                                                isLoading:
                                                    state.submissionStatus ==
                                                    FormzSubmissionStatus
                                                        .inProgress,
                                                backgroundColor: const Color(
                                                  0xFF1E3C72,
                                                ),
                                                foregroundColor: Colors.white,
                                                borderRadius: 15,
                                                elevation: 5,
                                                height: 56,
                                                // size: CoreButtonSize.large,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            CoreButton(
                                              onPressed: state.allowBiometric
                                                  ? () => handleFingerprint(
                                                      context,
                                                    )
                                                  : null,
                                              backgroundColor:
                                                  state.allowBiometric
                                                  ? const Color(0xFFF1F4F9)
                                                  : Colors.grey[200],
                                              borderRadius: 15,
                                              elevation: 0,
                                              height: 56,
                                              width: 56,
                                              padding: EdgeInsets.zero,
                                              child: Icon(
                                                Icons.fingerprint_rounded,
                                                size: 30,
                                                color: state.allowBiometric
                                                    ? const Color(0xFF1E3C72)
                                                    : Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    // CoreButton(
                                    //   text: "Demo Widget Global",
                                    //   type: CoreButtonType.outline,
                                    //   width: double.infinity,
                                    //   borderRadius: 15,
                                    //   onPressed: () {
                                    //     context.push('/widget-demo');
                                    //   },
                                    // ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                                FutureBuilder<String>(
                                  future: VersionUiHelper().getAppVersion(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text("Versi ...");
                                    }

                                    return Text("Versi ${snapshot.data}");
                                  },
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
