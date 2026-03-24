import 'package:flutter/material.dart';
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
                child: Column(
                  spacing: 18,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Langkah 1 dari 2",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SettlementInputCard(title: "Data Transaksi Melalui Kartu"),
                    SettlementInputCard(title: "Data Transaksi Melalui Brizzi"),
                    SettlementInputCard(title: "Data Transaksi Melalui QRIS"),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  "Selanjutnya",
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
