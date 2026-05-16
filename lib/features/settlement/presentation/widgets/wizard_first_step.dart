import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

class WizardFirstStep extends StatelessWidget {
  const WizardFirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) {
            ReferenceBus? selectedBus;

            if (state.referenceBus.isNotEmpty) {
              final matchedBus = state.referenceBus.where(
                    (e) => e.id == state.idBus,
              );

              if (matchedBus.isNotEmpty) {
                selectedBus = matchedBus.first;
              }
            }

            return DropdownSearch<ReferenceBus>(
              items: (f, cs) => state.referenceBus,

              selectedItem: selectedBus,

              itemAsString: (item) =>
              '${item.nomorLambung} - ${item.platNomor}',

              compareFn: (a, b) => a.id == b.id,

              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Pilih Bus",
                  hintText: "Pilih Bus",
                  border: OutlineInputBorder(),
                ),
              ),

              popupProps: PopupProps.bottomSheet(
                showSearchBox: true,

                title: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Daftar Bus',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                bottomSheetProps: const BottomSheetProps(
                  clipBehavior: Clip.antiAlias,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),

              onSelected: (value) {
                if (value == null) return;

                context.read<SettlementBloc>().add(
                  SelectBus(value.id, value.platNomor),
                );
              },
            );
          },
        ),

        BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) {
            ReferenceDetail? selectedKoridor;

            if (state.referenceKoridor.isNotEmpty) {
              final matchedKoridor = state.referenceKoridor.where(
                    (e) => e.id == state.idKoridor,
              );

              if (matchedKoridor.isNotEmpty) {
                selectedKoridor = matchedKoridor.first;
              }
            }

            return DropdownSearch<ReferenceDetail>(
              items: (f, cs) => state.referenceKoridor,

              selectedItem: selectedKoridor,

              itemAsString: (item) => '${item.code} - ${item.name}',

              compareFn: (a, b) => a.id == b.id,

              decoratorProps: const DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Pilih Koridor",
                  hintText: "Pilih Koridor",
                  border: OutlineInputBorder(),
                ),
              ),

              popupProps: PopupProps.bottomSheet(
                showSearchBox: true,

                title: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Daftar Koridor',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                bottomSheetProps: const BottomSheetProps(
                  clipBehavior: Clip.antiAlias,
                  shape: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),

              onSelected: (value) {
                if (value == null) return;

                context.read<SettlementBloc>().add(
                  SelectKoridor(value.id, value.name),
                );
              },
            );
          },
        ),
      ],
    );
  }
}