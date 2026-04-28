import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CoreBottomModalAlert extends StatelessWidget {
  const CoreBottomModalAlert({
    super.key,
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final minHeight = size.height * 0.33;
    final maxHeight = size.height * 0.5;

    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight,
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    child: Lottie.asset(
                      success
                          ? 'assets/lottie/success.json'
                          : 'assets/lottie/failed.json',
                      animate: true,
                      repeat: false,
                      reverse: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}