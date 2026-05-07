import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_field.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class WizardDetailStep extends StatelessWidget {
  const WizardDetailStep({super.key, required this.currStep});
  final int currStep;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.status == SettlementStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.detail.isEmpty) {
          return const Center(child: Text("Data tidak tersedia"));
        }

        final Map<int, List<int>> groupedIndex = {};
        for (int i = 0; i < state.detail.length; i++) {
          final d = state.detail[i];
          groupedIndex.putIfAbsent(d.idPayment, () => []).add(i);
        }

        final paymentIds = groupedIndex.keys.toList();

        final index = currStep - 2;

        if (index < 0 || index >= paymentIds.length) {
          return const Center(child: Text("Step tidak valid"));
        }

        final selectedPaymentId = paymentIds[index];
        final indexes = groupedIndex[selectedPaymentId]!;

        final paymentName = index < state.labelPayment.length
            ? state.labelPayment[index]
            : "Payment $selectedPaymentId";

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...indexes.map((i) {
                final d = state.detail[i];

                final label = i < state.labelCustomer.length
                    ? state.labelCustomer[i]
                    : 'Customer ${d.idNasabah}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CoreInputField(
                    label: label,
                    initValue: d.total.toString(),
                    rule: InputRule.positiveNumber,
                    onChanged: (val) {
                      context.read<SettlementBloc>().add(
                        UpdateDetail(
                          idPayment: d.idPayment,
                          idNasabah: d.idNasabah,
                          total: int.tryParse(val) ?? 0,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}