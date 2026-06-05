import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_input_with_suffix_field.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class WizardDetailStep extends StatelessWidget {
  const WizardDetailStep({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: size.width * 0.05,
              right: size.width * 0.05,
              top: size.height * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                bottom: BorderSide(color: Color(0xFFB3B3B3), width: .65),
              ),
            ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(spacing: 5, children: [Text(state.noUnit)]),
                      ],
                    );
                  },
                ),

                BlocBuilder<SettlementBloc, SettlementState>(
                  buildWhen: (prev, curr) =>
                      prev.activeTabId != curr.activeTabIndex,
                  builder: (context, state) {
                    return Row(
                      children: [
                        ...state.referencePayment.asMap().entries.map((entry) {
                          final index = entry.key;
                          final payment = entry.value;

                          final isActive = payment.id == state.activeTabId;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.read<SettlementBloc>().add(
                                  ChangeTabDetail(index),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) => prev.activeTabId != curr.activeTabIndex,
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.03,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                    bottom: BorderSide(color: Color(0xFFB3B3B3), width: .65),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(width: .5, color: Colors.black87),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: BlocBuilder<SettlementBloc, SettlementState>(
                        builder: (context, state) {
                          final totalPenumpang = state.detail
                              .where(
                                (data) => data.idPayment == state.activeTabId,
                              )
                              .fold<int>(
                                0,
                                (sum, data) => sum + (data.total ?? 0),
                              );

                          final totalPerPayment = state.detail
                              .where(
                                (data) => data.idPayment == state.activeTabId,
                              )
                              .fold<int>(
                                0,
                                (sum, data) => sum + (data.value ?? 0),
                              );

                          final total = state.detail.fold<int>(
                            0,
                            (sum, data) => sum + (data.value ?? 0),
                          );

                          return Column(
                            children: [
                              SizedBox(
                                height: 48,
                                child: Row(
                                  spacing: 15,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (state.activeTabLabel.toUpperCase() ==
                                        "QRIS")
                                      Image.asset(
                                        "./assets/logo/qris.png",
                                        width: 50,
                                      ),
                                    if (state.activeTabLabel.toUpperCase() ==
                                        "BRIZI")
                                      Image.asset(
                                        "./assets/logo/brizzi.png",
                                        width: 50,
                                      ),
                                    if (state.activeTabLabel.toUpperCase() ==
                                        "DEBIT CARD")
                                      Image.asset(
                                        "./assets/logo/card.png",
                                        width: 50,
                                      ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.activeTabLabel.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          StringFormatter().idrFormatter(
                                            100000,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.black26,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Pendapatan",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        Text(
                                          StringFormatter().idrFormatter(
                                            totalPerPayment,
                                          ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total",
                                          style: TextStyle(fontSize: 10),
                                        ),
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
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            ...state.referenceCustomer.map((cust) {
                              final detail = state.detail.firstWhere(
                                (e) =>
                                    e.idPayment == state.activeTabId &&
                                    e.idNasabah == cust.id,
                              );

                              return CoreInputWithSuffixField(
                                label: cust.name,
                                isRequired: true,
                                suffixText: StringFormatter().idrFormatter(
                                  detail.billingValue!,
                                ),

                                initValue: detail.total?.toString(),

                                rule: InputRuleSuffix.positiveNumber,

                                onChanged: (val) {
                                  context.read<SettlementBloc>().add(
                                    UpdateDetail(
                                      idPayment: state.activeTabId,
                                      idNasabah: cust.id,
                                      total: int.tryParse(val) ?? 0,
                                      value: int.tryParse(val) != null
                                          ? int.tryParse(val)! *
                                                detail.billingValue!
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
            },
          ),
        ],
      ),
    );
  }
}
