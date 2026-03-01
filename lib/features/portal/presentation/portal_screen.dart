import 'package:flutter/material.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PSM Portal", style: TextStyle(fontSize: 30),),

              Padding(
                padding: const EdgeInsetsGeometry.symmetric(horizontal: 12.0),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal A")),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal B")),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal C")),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal D")),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal E")),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.white70),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: Text("Portal F")),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text("@Copyright D'Coding 2026"),
            ],
          ),
        ),
      ),
    );
  }
}
