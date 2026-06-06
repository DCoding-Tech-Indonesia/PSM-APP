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

                SizedBox(height: 10),

                BlocBuilder<SettlementBloc, SettlementState>(
                  buildWhen: (prev, curr) =>
                      prev.activeTabId != curr.activeTabId,
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 12) / 2;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: state.referencePayment.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final payment = entry.value;

                            final isActive = payment.id == state.activeTabId;

                            final logoMap = {
                              'QRIS': 'assets/logo/qris.png',
                              'BRIZI': 'assets/logo/brizzi.png',
                              'DEBIT CARD': 'assets/logo/card.png',
                            };

                            return SizedBox(
                              width: itemWidth,
                              child: GestureDetector(
                                onTap: () {
                                  context.read<SettlementBloc>().add(
                                    ChangeTabDetail(index),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: isActive ? 1.5 : 1,
                                      color: isActive
                                          ? Colors.blue
                                          : Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 4.5,
                                    child: Image.asset(
                                      logoMap[payment.name.toUpperCase()] ??
                                          "assets/logo/cash.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 10),

              ],
            ),
          ),

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
