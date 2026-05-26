import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_with_suffix_field.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class WizardDetailStepNew extends StatefulWidget {
  const WizardDetailStepNew({super.key});

  @override
  State<WizardDetailStepNew> createState() => _WizardDetailStepNewState();
}

class _WizardDetailStepNewState extends State<WizardDetailStepNew> {
  int selectedPaymentMethod = 0;
  String? selectedPaymentLabel;

  void _changeTab(int val, String valLabel) {
    setState(() {
      selectedPaymentMethod = val;
      selectedPaymentLabel = valLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) =>
                prev.namaKoridor != curr.namaKoridor ||
                prev.noUnit != curr.noUnit,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.namaKoridor,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Text(state.noUnit),
                    ],
                  ),
                ],
              );
            },
          ),

          BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              return Row(
                children: [
                  ...state.referencePayment.map((payment) {
                    final isActive = payment.id == selectedPaymentMethod;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _changeTab(payment.id, payment.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: isActive
                                  ? Colors.blueAccent
                                  : Colors.grey,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            child: Text(payment.name),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          if (selectedPaymentMethod != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(width: .5, color: Colors.black87),
                borderRadius: BorderRadius.circular(6),
              ),
              child: BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) {
                  final totalPenumpang = state.detail
                      .where((data) => data.idPayment == selectedPaymentMethod)
                      .fold<int>(0, (sum, data) => sum + data.total);

                  final totalPerPayment = state.detail
                      .where((data) => data.idPayment == selectedPaymentMethod)
                      .fold<int>(0, (sum, data) => sum + data.value);

                  final total = state.detail
                      .fold<int>(0, (sum, data) => sum + data.value);

                  return Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          spacing: 15,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (selectedPaymentLabel!.toUpperCase() == "QRIS")
                              Image.asset("./assets/logo/qris.png", width: 50),
                            if (selectedPaymentLabel!.toUpperCase() == "BRIZI")
                              Image.asset("./assets/logo/brizzi.png", width: 50),
                            if (selectedPaymentLabel!.toUpperCase() == "DEBIT CARD")
                              Image.asset("./assets/logo/card.png", width: 50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedPaymentLabel.toString(),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(StringFormatter().idrFormatter(100000)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, color: Colors.black26),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Penumpang",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  totalPenumpang.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Pendapatan",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  StringFormatter().idrFormatter(totalPerPayment),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total", style: TextStyle(fontSize: 10)),
                                Text(
                                  StringFormatter().idrFormatter(total),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),
            ),

          const SizedBox(height: 10),

          if (selectedPaymentMethod != 0)
            BlocBuilder<SettlementBloc, SettlementState>(
              builder: (context, state) {
                return Column(
                  children: [
                    ...state.referenceCustomer.map((cust) {
                      final detail = state.detail.firstWhere(
                        (e) =>
                            e.idPayment == selectedPaymentMethod &&
                            e.idNasabah == cust.id,
                      );

                      return CoreInputWithSuffixField(
                        label: cust.name,
                        suffixText: StringFormatter().idrFormatter(
                          detail.billingValue,
                        ),

                        initValue: detail.total.toString(),

                        rule: InputRuleSuffix.positiveNumber,

                        onChanged: (val) {
                          context.read<SettlementBloc>().add(
                            UpdateDetail(
                              idPayment: selectedPaymentMethod,
                              idNasabah: cust.id,
                              total: int.tryParse(val) ?? 0,
                              value: int.tryParse(val) != null
                                  ? int.tryParse(val)! * detail.billingValue
                                  : 0,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
