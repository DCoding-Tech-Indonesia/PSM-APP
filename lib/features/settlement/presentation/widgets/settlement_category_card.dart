import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';

class SettlementCategoryCard extends StatelessWidget {
  const SettlementCategoryCard({
    super.key,
    required this.cardKey,
    this.isFocused = false,
    required this.label,
  });

  final bool isFocused;
  final String cardKey, label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.read<SettlementCategoryCubit>().changeSettlementCategory(cardKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              width: 1.5,
              color: isFocused ? theme.primaryColor : Colors.transparent
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label),
              ],
            ),
            Row(
              children: [
                Text("0"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}