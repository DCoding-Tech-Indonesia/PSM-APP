import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/wizard_last_step_date_time.dart';

class WizardLastStep extends StatefulWidget {
  const WizardLastStep({super.key});

  @override
  State<WizardLastStep> createState() => _WizardLastStepState();
}

class _WizardLastStepState extends State<WizardLastStep> {
  int _indexDetail = 0;
  String _selectedDetail = '';
  int _totalTransaction = 0;

  void _changeTabDetail(int index, String val) {
    var selectedIndex = 0;
    if (index == 0) {
      selectedIndex = 0;
    } else if (index == 1) {
      selectedIndex = 3;
    } else if (index == 2) {
      selectedIndex = 5;
    } else {
      selectedIndex = 9;
    }
    setState(() {
      _indexDetail = selectedIndex;
      _selectedDetail = val;
    });
  }

  @override
  void initState() {
    super.initState();

    final state = context.read<SettlementBloc>().state;

    if (state.detail.isNotEmpty) {
      _totalTransaction = state.detail.fold(0, (sum, item) => sum + item.total);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final paymentMethods = state.labelPayment;
        final customerTypes = state.labelCustomer;
        final customerTypesFiltered = customerTypes.toSet().toList();

        print(customerTypesFiltered);

        String getIcon(String method) {
          switch (method) {
            case "Credit Card":
              return "assets/logo/card.png";
            case "BRIZI":
              return "assets/logo/brizzi.png";
            case "CASH":
              return "assets/logo/cash.png";
            case "QRIS":
              return "assets/logo/qris.png";
            default:
              return "assets/logo/default.png";
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 15,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.namaKoridor != '' ? state.namaKoridor : '-',
                    softWrap: true,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    state.noUnit != '' ? state.noUnit : '-',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    StringFormatter().idrFormatter(_totalTransaction),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  WizardLastStepDateTime(),
                ],
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paymentMethods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  final item = paymentMethods[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      _changeTabDetail(index, item);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: _selectedDetail == item
                            ? LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _selectedDetail == item
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Image.asset(
                              getIcon(item),
                              height: 26,
                              width: 26,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedDetail == item
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _selectedDetail == item
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 10),

              if (_selectedDetail.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tipe Pembayaran"),
                        Text(_selectedDetail),
                      ],
                    ),

                    const SizedBox(height: 8),

                    ...customerTypesFiltered.asMap().entries.map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.value),
                            BlocBuilder<SettlementBloc, SettlementState>(
                              builder: (context, state) {
                                return Text(
                                  StringFormatter().idrFormatter(
                                    state.detail[_indexDetail + data.key].total,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(),

                    BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, state) {
                        final total = _selectedDetail.isEmpty
                            ? 0
                            : customerTypesFiltered.asMap().entries.fold(0, (
                                sum,
                                entry,
                              ) {
                                final index = _indexDetail + entry.key;

                                if (index >= state.detail.length) return sum;

                                return sum + state.detail[index].total;
                              });
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              StringFormatter().idrFormatter(total),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
