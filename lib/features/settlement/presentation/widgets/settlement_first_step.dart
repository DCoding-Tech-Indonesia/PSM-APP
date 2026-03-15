import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_category_card.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_method_wizard_item.dart';

class SettlementFirstStep extends StatelessWidget {
  const SettlementFirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementTabCubit, String>(
      builder: (context, state) {
        final categoryTab = state;
        return Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 10),
            const Text("Kategori", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            BlocBuilder<SettlementCategoryCubit, String>(
              builder: (context, state) {
                return Expanded(
                  child: Column(
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
                  ),
                );
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                Text("Rp -", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              ],
            ),
          ],
        );
      },
    );
  }
}
