import 'package:flutter/material.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_input_card.dart';

class SettlementAddScreen extends StatelessWidget {
  const SettlementAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: false,
        title: const Text("Submit Settlement"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Color(0xFFFAFAFA)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    spacing: 18,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Text(
                      //     "Langkah 1 dari 2",
                      //     style: TextStyle(fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui Kartu",
                        method: "card",
                      ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui Brizzi",
                        method: "brizzi",
                      ),
                      SettlementInputCard(
                        title: "Data Transaksi Melalui QRIS",
                        method: "qris",
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white
                        ),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "Unggah Foto Bukti Settlement",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){},
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: .5
                                  )
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_rounded),
                                    Text("Format: PNG/JPG, Max 2mb")
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
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: CoreStyling.coreActiveButtonGradient,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "Simpan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
