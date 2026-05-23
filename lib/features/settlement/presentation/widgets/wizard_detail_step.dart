import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      paymentName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (paymentName.toUpperCase() == 'CREDIT CARD')
                      Image.asset("assets/logo/card.png", height: 32),
                    if (paymentName.toUpperCase() == 'BRIZI')
                      Image.asset("assets/logo/brizzi.png", height: 32),
                    if (paymentName.toUpperCase() == 'CASH')
                      Image.asset("assets/logo/cash.png", height: 32),
                    if (paymentName.toUpperCase() == 'QRIS')
                      Image.asset("assets/logo/qris.png", height: 32),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ...indexes.map((i) {
                final valInput = state.detail[i];
                final detInput = state.detailInput[i];

                final label = i < state.labelCustomer.length
                    ? state.labelCustomer[i]
                    : 'Customer ${valInput.idNasabah}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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

              const SizedBox(height: 16),

              BlocBuilder<SettlementBloc, SettlementState>(
                buildWhen: (prev, curr) =>
                    prev.detail != curr.detail || prev.steps != curr.steps,
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

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total :",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          StringFormatter().idrFormatter(total),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
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
