import 'package:flutter/material.dart';
import 'package:psm_mobile/features/portal/presentation/widget/portal_menu_widget.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.6),
              theme.primaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  spacing: 14,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white70,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          "https://picsum.photos/id/64/300/300",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      "Jane Doe",
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        PortalMenuWidget(
                          title: "Settlement",
                          route: "/settlement/dashboard",
                        ),
                        const SizedBox(width: 16),
                        PortalMenuWidget(title: "Absensi", route: "/absensi"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        PortalMenuWidget(
                          title: "Data Kendaraan",
                          route: "/kendaraan",
                        ),
                        const SizedBox(width: 16),
                        PortalMenuWidget(title: "Ceklis SPM", route: "/spm"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        PortalMenuWidget(title: "KM Kendaraan", route: "/km"),
                        const SizedBox(width: 16),
                        PortalMenuWidget(title: "Report", route: "/report"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
