import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';

class SettlementCategoryCard extends StatelessWidget {
  const SettlementCategoryCard({
    super.key,
    required this.category,
    required this.cardKey,
    this.isFocused = false,
    required this.label,
  });

  final bool isFocused;
  final String category, cardKey, label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.read<SettlementCategoryCubit>().changeSettlementCategory(
          cardKey,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1.5,
            color: isFocused ? theme.primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Text(label)]),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 3,
                horizontal: 4,
              ),
              decoration: BoxDecoration(
              ),
              child: BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  final value = state.paymentData[category]?[cardKey] ?? 0;

                  return Row(
                    spacing: 15,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<SettlementCategoryCubit>().changeSettlementCategory(
                            cardKey,
                          );
                          if (value > 0) {
                            context.read<SettlementBloc>().add(
                              PaymentCountChanged(
                                method: category,
                                category: cardKey,
                                value: value - 1,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              width: 1.3,
                              color: value > 0 ? theme.primaryColor : theme.disabledColor,
                            ),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: value > 0 ? theme.primaryColor : theme.disabledColor,
                          ),
                        ),
                      ),

                      Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          context.read<SettlementCategoryCubit>().changeSettlementCategory(
                            cardKey,
                          );
                          context.read<SettlementBloc>().add(
                            PaymentCountChanged(
                              method: category,
                              category: cardKey,
                              value: value + 1,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              width: 1.3,
                              color: theme.primaryColor,
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}
