import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
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
                  const Text(
                    "Ritase",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_transit_rounded,
                          color: Color(0xFF1565C0),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.ritase != 0 
                              ? 'Ritase ${state.ritase % 1 == 0 ? state.ritase.toInt() : state.ritase}'
                              : "Belum Ditentukan",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
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
                readOnly: true,
                label: 'Pilih Koridor',
                hintText: 'Pilih Koridor',
                popupTitle: 'Daftar Koridor',
                items: state.referenceKoridor,
                selectedItem: selectedKoridor,
                itemAsString: (item) => '${item.code} - ${item.name}',
                compareFn: (a, b) => a.id == b.id,
                isRequired: true,
                isItemSelected: (item) => item.id == state.idKoridor,
                onSelected: (value) {
                  if (value == null) return;
                  context.read<SettlementBloc>().add(
                    SelectKoridor(value.id, value.name),
                  );
                },
              );
            },
          ),

          SizedBox(height: 8),

          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) => prev.idKoridor != curr.idKoridor || prev.referenceBus != curr.referenceBus,
            builder: (context, state) {
              ReferenceDetail? selectedBus;

              if (state.referenceBus.isNotEmpty) {
                final matched = state.referenceBus.where(
                  (e) => e.id == state.idBus,
                );
                if (matched.isNotEmpty) selectedBus = matched.first;
              }

              if (state.referenceBus.isEmpty && state.idKoridor != 0 && state.status != SettlementStatus.fetching) {
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

              return CoreDropdownSearch<ReferenceDetail>(
                readOnly: true,
                label: 'Pilih Bus',
                hintText: 'Pilih Bus',
                popupTitle: 'Daftar Bus',
                items: state.referenceBus,
                selectedItem: selectedBus,
                itemAsString: (item) =>
                    '${item.code} - ${item.name}',
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (item) => item.id == state.idBus,
                isRequired: true,
                onSelected: (value) {
                  if (value == null) return;
                  context.read<SettlementBloc>().add(
                    SelectBus(value.id, value.name),
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
