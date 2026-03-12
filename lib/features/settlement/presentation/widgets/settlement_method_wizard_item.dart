import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';

class SettlementMethodWizardItem extends StatelessWidget {
  const SettlementMethodWizardItem({
    super.key,
    required this.wizardKey,
    required this.active,
    required this.label
  });

  final bool active;
  final String wizardKey, label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<SettlementTabCubit>().changeSettlementTab(wizardKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            border: BoxBorder.all(
              color: active ? theme.primaryColor : Colors.black26,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}