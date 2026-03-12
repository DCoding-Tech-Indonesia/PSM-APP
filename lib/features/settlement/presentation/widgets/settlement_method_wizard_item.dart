import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';

class SettlementMethodWizardItem extends StatelessWidget {
  const SettlementMethodWizardItem({
    super.key,
    required this.wizardKey,
    required this.active,
    required this.logoName,
  });

  final bool active;
  final String wizardKey, logoName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SettlementCategoryCubit>().changeSettlementCategory("pelajar");
          context.read<SettlementTabCubit>().changeSettlementTab(wizardKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? theme.primaryColor : Colors.black12,
              width: active ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: SizedBox(
              height: 32,
              child: Image.asset(
                "assets/logo/$logoName",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}