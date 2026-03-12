import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/brizzi_tab_content.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/debit_kredit_tab_content.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/qris_tab_content.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_method_wizard_item.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_tab.dart';

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
        title: const Text("Submit Settlement"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 12),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
          child: BlocBuilder<SettlementTabCubit, String>(
            builder: (context, state) {
              return Column(
                spacing: 15,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Detail Transaksi",
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.start,
                  ),
                  Divider(color: Colors.black26),
                  Row(
                    spacing: 12,
                    children: [
                      SettlementMethodWizardItem(
                        active: state == "card",
                        wizardKey: "card",
                        label: "Card",
                      ),
                      SettlementMethodWizardItem(
                        active: state == "brizzi",
                        wizardKey: "brizzi",
                        label: "BRIZZI",
                      ),
                      SettlementMethodWizardItem(
                        active: state == "qris",
                        wizardKey: "qris",
                        label: "QRIS",
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Denominasi",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
