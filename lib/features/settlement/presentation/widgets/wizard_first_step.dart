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
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pilih Bus ──────────────────────────────────────────────────
        BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) {
            ReferenceBus? selectedBus;

            if (state.referenceBus.isNotEmpty) {
              final matched = state.referenceBus.where(
                (e) => e.id == state.idBus,
              );
              if (matched.isNotEmpty) selectedBus = matched.first;
            }

            return CoreDropdownSearch<ReferenceBus>(
              label: 'Pilih Bus',
              popupTitle: 'Daftar Bus',
              items: state.referenceBus,
              selectedItem: selectedBus,
              itemAsString: (item) =>
                  '${item.nomorLambung} - ${item.platNomor}',
              compareFn: (a, b) => a.id == b.id,
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

        SizedBox(height: 8),

        // ── Pilih Koridor ───────────────────────────────────────────────
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
