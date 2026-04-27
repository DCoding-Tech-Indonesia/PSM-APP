import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     theme.primaryColor,
          //     theme.primaryColor.withOpacity(0.6),
          //     theme.primaryColor,
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 12),
            child: Column(
              children: [
                const Column(
                  children: [
                    Text("Bakureh"),
                    Text("Cari Pitih Untuak Anak Bini Sanak", style: TextStyle(color: CoreStyling.primaryColor, fontSize: 20, fontWeight: FontWeight.w700),),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                context.push('/settlement/dashboard');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(1.2, 1.2),
                                      blurRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(-1.2, 1.2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset("assets/icon/settlement.png", width: 80),
                                    const SizedBox(height: 15),
                                    const Text(
                                      "Settlement",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                context.push('/login');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(1.2, 1.2),
                                      blurRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(-1.2, 1.2),
                                      blurRadius: 2,
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset("assets/icon/logout.png", width: 80),
                                    const SizedBox(height: 15),
                                    const Text(
                                      "Logout",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
