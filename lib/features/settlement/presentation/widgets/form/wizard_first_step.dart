import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class WizardFirstStep extends StatelessWidget {
  const WizardFirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.03,
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) => prev.ritase != curr.ritase,
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ritase",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(width: 1, color: Colors.green),
                    ),
                    child: Center(
                      child: Text(
                        state.ritase != 0 ? state.ritase.toString() : "RIT",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 8),

          BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              ReferenceDetail? selectedKoridor;

              if (state.referenceKoridor.isNotEmpty) {
                final matched = state.referenceKoridor.where(
                  (e) => e.id == state.idKoridor,
                );
                if (matched.isNotEmpty) selectedKoridor = matched.first;
              }

              return CoreDropdownSearch<ReferenceDetail>(
                label: 'Pilih Koridor',
                popupTitle: 'Daftar Koridor',
                items: state.referenceKoridor,
                selectedItem: selectedKoridor,
                itemAsString: (item) => '${item.code} - ${item.name}',
                compareFn: (a, b) => a.id == b.id,
                isRequired: true,
                isItemSelected: (item) => item.id == state.idKoridor,
                onSelected: (value) {
                  if (value == null) return;
                  print("value");
                  print(value.id);
                  context.read<SettlementBloc>().add(
                    SelectKoridor(value.id, value.name),
                  );
                },
              );
            },
          ),

          SizedBox(height: 8),

          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) => prev.idKoridor != curr.idKoridor,
            builder: (context, state) {
              ReferenceBus? selectedBus;

              if (state.referenceBus.isNotEmpty) {
                final matched = state.referenceBus.where(
                  (e) => e.id == state.idBus,
                );
                if (matched.isNotEmpty) selectedBus = matched.first;
              }

              if (state.referenceBus.isEmpty && state.idKoridor != 0) {
                return const Text(
                  "Tidak terdapat bus terdata di koridor tersebut",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              if (state.idKoridor == 0 || state.referenceBus.isEmpty) {
                return SizedBox(height: 0);
              }

              return CoreDropdownSearch<ReferenceBus>(
                label: 'Pilih Bus',
                popupTitle: 'Daftar Bus',
                items: state.referenceBus,
                selectedItem: selectedBus,
                itemAsString: (item) =>
                    '${item.nomorLambung} - ${item.platNomor}',
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (item) => item.id == state.idBus,
                isRequired: true,
                onSelected: (value) {
                  if (value == null) return;
                  context.read<SettlementBloc>().add(
                    SelectBus(value.id, value.platNomor),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
