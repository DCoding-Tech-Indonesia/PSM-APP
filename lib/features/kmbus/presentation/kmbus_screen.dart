import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';

class KmbusScreen extends StatelessWidget {
  const KmbusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CoreHeader(
              title: "KM Bus",
              customBgColor: Colors.white,
              withBorder: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: CoreButton(
                      onPressed: () async {
                        await context.push('/kmbus/titik-awal/form');

                        if (context.mounted) {
                          // context.read<SettlementBloc>().add(PageDashboardLoad());
                        }
                      },
                      backgroundColor: Colors.green,
                      borderColor: Colors.greenAccent,
                      child: const Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.start, color: Colors.white),
                          Text(
                            "Titik Awal",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: CoreButton(
                      onPressed: () {},
                      backgroundColor: Colors.red,
                      borderColor: Colors.redAccent,
                      child: const Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.start, color: Colors.white),
                          Text(
                            "Titik Akhir",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
}
