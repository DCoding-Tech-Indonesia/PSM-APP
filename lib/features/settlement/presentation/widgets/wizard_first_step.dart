import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            return DropdownButtonFormField<int>(
              value: state.idBus == 0 ? null : state.idBus,
              decoration: const InputDecoration(
                labelText: "No Bus",
                border: OutlineInputBorder(),
              ),
              items: state.referenceBus.map((bus) {
                return DropdownMenuItem<int>(
                  value: bus.id,
                  child: Text('${bus.nomorLambung} - ${bus.platNomor}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = state.referenceBus.firstWhere(
                      (bus) => bus.id == value,
                );
                context.read<SettlementBloc>().add(
                  SelectBus(selected.id, selected.platNomor),
                );
              },
            );
          },
        ),
        BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) {
            return DropdownButtonFormField<int>(
              value: state.idKoridor == 0 ? null : state.idKoridor,
              decoration: const InputDecoration(
                labelText: "Koridor",
                border: OutlineInputBorder(),
              ),
              items: state.referenceKoridor.map((koridor) {
                return DropdownMenuItem<int>(
                  value: koridor.id,
                  child: Text('${koridor.code} - ${koridor.name}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = state.referenceKoridor.firstWhere(
                      (koridor) => koridor.id == value,
                );
                context.read<SettlementBloc>().add(
                  SelectKoridor(selected.id, selected.name),
                );
              },
            );
          },
        ),
      ],
    );
  }
}