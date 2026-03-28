import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_field.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
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
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 52),
                  padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, -15),
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
                                const Center(
                                  child: Column(
                                    children: [
                                      Text("Masuek la sanak."),
                                      Text("Pitih dapek dicari,"),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Column(
                                  children: [
                                    CoreInputField(
                                      label: "Email",
                                      keyInput: "email",
                                      hintText: "email@example.com",
                                      isRequired: true,
                                      rule: InputRule.text,
                                      onChanged: (value) {},
                                    ),
                                    const SizedBox(height: 12),
                                    CoreInputField(
                                      label: "Password",
                                      keyInput: "password",
                                      hintText: "********",
                                      isRequired: true,
                                      isSecured: true,
                                      rule: InputRule.text,
                                      onChanged: (value) {},
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: false,
                                          onChanged: (value) {},
                                        ),
                                        const Text("Ingek Aden"),
                                      ],
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
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF3D3D3D),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "Masuek",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3D3D3D),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fingerprint,
                                          color: Colors.white,
                                        ),
                                      ),
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
    );
  }
}
