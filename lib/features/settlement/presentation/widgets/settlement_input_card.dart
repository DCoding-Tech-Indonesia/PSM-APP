import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_field.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class SettlementInputCard extends StatelessWidget {
  const SettlementInputCard({
    super.key,
    required this.title,
    required this.method,
  });

  final String title, method;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            spacing: 10,
            children: [
              CoreInputField(
                label: "Pelajar",
                keyInput: "pelajar",
                hintText: "Masukkan total pelajar",
                isRequired: true,
                rule: InputRule.positiveNumber,
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;

                  context.read<SettlementBloc>().add(
                    PaymentCountChanged(
                      method: method,
                      category: "pelajar",
                      value: intValue,
                    ),
                  );
                },
              ),
              CoreInputField(
                label: "Umum",
                keyInput: "umum",
                hintText: "Masukkan total umum",
                isRequired: true,
                rule: InputRule.positiveNumber,
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;

                  context.read<SettlementBloc>().add(
                    PaymentCountChanged(
                      method: method,
                      category: "umum",
                      value: intValue,
                    ),
                  );
                },
              ),
              CoreInputField(
                label: "Lansia",
                keyInput: "lansia",
                hintText: "Masukkan total lansia",
                rule: InputRule.positiveNumber,
                onChanged: (value) {
                  final intValue = int.tryParse(value) ?? 0;

                  context.read<SettlementBloc>().add(
                    PaymentCountChanged(
                      method: method,
                      category: "lansia",
                      value: intValue,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}