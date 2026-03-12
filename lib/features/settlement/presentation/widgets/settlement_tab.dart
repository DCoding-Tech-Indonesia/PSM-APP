import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';

class SettlementTab extends StatelessWidget {
  const SettlementTab({super.key, required this.label, required this.keyword});

  final String label, keyword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettlementTabCubit, String>(
      builder: (context, state) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<SettlementTabCubit>().changeSettlementTab(keyword);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.primaryColor,
                    width: state == keyword ? 3 : 1,
                  ),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: state == keyword
                      ? theme.primaryColor
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
