import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_field.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_with_suffix_field.dart';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    paymentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (paymentName.toUpperCase() == 'CREDIT CARD')
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset("./assets/logo/card.png", height: 35),
                    ),
                  if (paymentName.toUpperCase() == 'BRIZI')
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset(
                        "./assets/logo/brizzi.png",
                        height: 35,
                      ),
                    ),
                  if (paymentName.toUpperCase() == 'CASH')
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset("./assets/logo/cash.png", height: 35),
                    ),
                  if (paymentName.toUpperCase() == 'QRIS')
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Image.asset("./assets/logo/qris.png", height: 35),
                    ),
                ],
              ),
          
              const SizedBox(height: 10),
          
              ...indexes.map((i) {
                final valInput = state.detail[i];
                final detInput = state.detailInput[i];
          
                final label = i < state.labelCustomer.length
                    ? state.labelCustomer[i]
                    : 'Customer ${valInput.idNasabah}';
          
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CoreInputWithSuffixField(
                    label: label,
                    suffixText: StringFormatter().idrFormatter(detInput.value),
                    initValue: valInput.total.toString(),
                    rule: InputRuleSuffix.positiveNumber,
                    onChanged: (val) {
                      context.read<SettlementBloc>().add(
                        UpdateDetail(
                          idPayment: valInput.idPayment,
                          idNasabah: valInput.idNasabah,
                          total: int.tryParse(val) ?? 0,
                          value: int.tryParse(val)! * detInput.value,
                        ),
                      );
                    },
                  ),
                );
              }),

              const Divider(),

              BlocBuilder<SettlementBloc, SettlementState>(
                buildWhen: (prev, curr) => prev.detail != curr.detail || prev.steps != curr.steps,
                builder: (context, state) {
                  final startIndex = (state.steps - 2) * 3;
                  final endIndex = startIndex + 3;

                  final currentItems = state.detail.sublist(
                    startIndex,
                    endIndex > state.detail.length
                        ? state.detail.length
                        : endIndex,
                  );

                  final total = currentItems.fold<int>(
                    0,
                        (sum, item) => sum + item.value,
                  );
          
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total :",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        StringFormatter().idrFormatter(total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
