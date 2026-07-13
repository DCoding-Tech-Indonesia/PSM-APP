import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_state.dart';

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
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single Information Card for Ritase, Koridor, and Bus
          BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) =>
                prev.ritase != curr.ritase ||
                prev.namaKoridor != curr.namaKoridor ||
                prev.noUnit != curr.noUnit,
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE3F2FD),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFF1565C0),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Informasi Perjalanan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    
                    // Ritase Row
                    Row(
                      children: [
                        Icon(
                          Icons.directions_transit_rounded,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Ritase",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            state.ritase != 0
                                ? '${state.ritase % 1 == 0 ? state.ritase.toInt() : state.ritase}'
                                : "-",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Koridor and Bus Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    color: Colors.grey.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Koridor",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.namaKoridor.isNotEmpty
                                    ? state.namaKoridor
                                    : "-",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_bus_rounded,
                                    color: Colors.grey.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Bus",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.noUnit.isNotEmpty ? state.noUnit : "-",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
