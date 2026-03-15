import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/theme/core_styling.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_step_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_first_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_second_step.dart';

class SettlementAddScreen extends StatelessWidget {
  const SettlementAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: const Text("Submit Settlement"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0XFFEFEFEF),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detail Transaksi",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.start,
              ),
              Divider(color: Colors.black26),
              Expanded(
                child: BlocBuilder<SettlementStepCubit, int>(
                  builder: (context, state) {
                    if (state != 0) {
                      return SettlementSecondStep();
                    }
                    return SettlementFirstStep();
                  },
                ),
              ),
              BlocBuilder<SettlementStepCubit, int>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(state == 0) return;
                          context.read<SettlementStepCubit>().changeSettlementStep(0);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: state == 0 ? CoreStyling.coreDisableButtonGradient : CoreStyling.coreActiveButtonGradient,
                            borderRadius: CoreStyling.coreButtonRadius,
                          ),
                          child: Text(
                            "Previous",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if(state == 1) return;
                          context.read<SettlementStepCubit>().changeSettlementStep(1);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: CoreStyling.coreActiveButtonGradient,
                            borderRadius: CoreStyling.coreButtonRadius,
                          ),
                          child: Text(
                            "Next",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
