import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_category_card.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_method_wizard_item.dart';

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
              final categoryTab = state;

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
                        logoName: "card.png",
                      ),
                      SettlementMethodWizardItem(
                        active: state == "brizzi",
                        wizardKey: "brizzi",
                        logoName: "brizzi.png",
                      ),
                      SettlementMethodWizardItem(
                        active: state == "qris",
                        wizardKey: "qris",
                        logoName: "qris.png",
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Kategori",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  BlocBuilder<SettlementCategoryCubit, String>(
                    builder: (context, state) {

                      return Column(
                        spacing: 8,
                        children: [
                          SettlementCategoryCard(
                            category: categoryTab,
                            cardKey: "pelajar",
                            label: "Pelajar",
                            isFocused: state == "pelajar",
                          ),
                          SettlementCategoryCard(
                            category: categoryTab,
                            cardKey: "umum",
                            label: "Umum",
                            isFocused: state == "umum",
                          ),
                          SettlementCategoryCard(
                            category: categoryTab,
                            cardKey: "lansia",
                            label: "Lansia",
                            isFocused: state == "lansia",
                          ),
                        ],
                      );
                    },
                  ),
                  Expanded(child: Text("Total")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: theme.disabledColor,
                          ),
                          child: Text(
                            "Previous",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: theme.primaryColor,
                          ),
                          child: Text(
                            "Next",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
