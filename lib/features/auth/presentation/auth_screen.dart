import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_alert.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_field.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();

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

    final authBloc = context.read<AuthBloc>();
    authBloc.add(LoadSavedCredentials());

    final currentState = authBloc.state;
    if (currentState.allowBiometric == true) {
      handleFingerprint(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (previous.pageLoaded != current.pageLoaded ||
          previous.popup != current.popup ||
          previous.allowBiometric != current.allowBiometric),
      listener: (context, state) {
        if (!state.popup) return;

        final isSuccess = state.loginSuccess;

        showModalBottomSheet(
          context: context,
          builder: (_) => CoreBottomModalAlert(
            success: isSuccess,
            message: state.loginMessage,
          ),
        ).then((_) {
          context.read<AuthBloc>().add(ResetState());
        });

        if (isSuccess) {
          Future.delayed(const Duration(seconds: 3), () {
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
              colors: [Color(0xFF2275d9), Color(0xff508cd3), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "PSM",
                      style: TextStyle(
                        fontSize: 68,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Padang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Sejahtera",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Mandiri.",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 52),
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Masuek la sanak.",
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      SizedBox(height: 12),
                                      Text("Pitih dapek dicari,"),
                                      Text(
                                        "hiduik cuma sekali, stay hepi sanak",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Column(
                                    children: [
                                      BlocBuilder<AuthBloc, AuthState>(
                                        buildWhen: (prev, curr) =>
                                            prev.username != curr.username,
                                        builder: (context, state) {
                                          return CoreInputField(
                                            label: "Username",
                                            keyInput: "username",
                                            hintText: "username",
                                            isRequired: true,
                                            rule: InputRule.text,
                                            initValue: state.username,
                                            onChanged: (value) {
                                              context.read<AuthBloc>().add(
                                                UsernameChanged(value),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        buildWhen: (prev, curr) =>
                                            prev.password != curr.password,
                                        builder: (context, state) {
                                          return CoreInputField(
                                            label: "Password",
                                            keyInput: "password",
                                            hintText: "********",
                                            isRequired: true,
                                            isSecured: true,
                                            rule: InputRule.text,
                                            initValue: state.password.value,
                                            onChanged: (value) {
                                              context.read<AuthBloc>().add(
                                                PasswordChanged(value),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return Row(
                                            children: [
                                              Checkbox(
                                                value: state.rememberMe,
                                                onChanged: (value) {
                                                  context.read<AuthBloc>().add(
                                                    RememberMeToggled(
                                                      value ?? false,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const Text("Ingek Aden"),
                                            ],
                                          );
                                        },
                                      ),
                                      Text(
                                        "Lupo password sanak?",
                                        style: TextStyle(
                                          color: CoreStyling.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BlocBuilder<AuthBloc, AuthState>(
                                          builder: (context, state) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  _loginPressed(context),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: CoreStyling
                                                      .coreActiveButtonGradient,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    "Masuek",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return GestureDetector(
                                            onTap: state.allowBiometric
                                                ? () =>
                                                      handleFingerprint(context)
                                                : null,
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: state.allowBiometric
                                                    ? CoreStyling.primaryColor
                                                    : Color(0xFF3D3D3D),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: const Icon(
                                                Icons.fingerprint,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
