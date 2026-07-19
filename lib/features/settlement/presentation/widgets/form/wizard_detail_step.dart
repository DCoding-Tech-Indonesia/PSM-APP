import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travis/core/helper/string_formatter.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_state.dart';

class WizardDetailStep extends StatelessWidget {
  const WizardDetailStep({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: 8,
              ),
              child: Column(
                children: [
                  BlocBuilder<SettlementBloc, SettlementState>(
                    buildWhen: (prev, curr) =>
                        prev.namaKoridor != curr.namaKoridor ||
                        prev.noUnit != curr.noUnit,
                    builder: (context, state) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              state.namaKoridor,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1565C0,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_bus_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.noUnit,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

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
                            children: state.referencePayment
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final payment = entry.value;

                                  final isActive =
                                      payment.id == state.activeTabId;

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
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            width: isActive ? 2 : 1.2,
                                            color: isActive
                                                ? const Color(0xFF1565C0)
                                                : Colors.grey.shade200,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isActive
                                                  ? const Color(
                                                      0xFF1565C0,
                                                    ).withValues(alpha: 0.1)
                                                  : Colors.black.withValues(
                                                      alpha: 0.02,
                                                    ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 26,
                                              child: Image.asset(
                                                logoMap[payment.name
                                                        .toUpperCase()] ??
                                                    "assets/logo/cash.png",
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              payment.name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: isActive
                                                    ? const Color(0xFF1565C0)
                                                    : const Color(0xFF718096),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            BlocBuilder<SettlementBloc, SettlementState>(
              buildWhen: (prev, curr) =>
                  prev.activeTabId != curr.activeTabIndex,
              builder: (context, state) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      BlocBuilder<SettlementBloc, SettlementState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              ...state.referenceCustomer.asMap().entries.map((
                                entry,
                              ) {
                                final cust = entry.value;

                                final detail = state.detail.firstWhere(
                                  (e) =>
                                      e.idPayment == state.activeTabId &&
                                      e.idNasabah == cust.id,
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey.withValues(
                                        alpha: 0.15,
                                      ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cust.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFE8F5E9,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    StringFormatter()
                                                        .idrFormatter(
                                                          detail.billingValue!,
                                                        ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF2E7D32),
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  final currentQty =
                                                      detail.total ?? 0;
                                                  if (currentQty > 0) {
                                                    final newQty =
                                                        currentQty - 1;
                                                    context
                                                        .read<SettlementBloc>()
                                                        .add(
                                                          UpdateDetail(
                                                            idPayment: state
                                                                .activeTabId,
                                                            idNasabah: cust.id,
                                                            total: newQty,
                                                            value:
                                                                newQty *
                                                                detail
                                                                    .billingValue!,
                                                          ),
                                                        );
                                                  }
                                                },
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFF7FAFC,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFE2E8F0,
                                                      ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove_rounded,
                                                    color: Color(0xFF4A5568),
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 45,
                                                child: TextFormField(
                                                  key: ValueKey(
                                                    '${state.activeTabId}_${cust.id}',
                                                  ),
                                                  initialValue:
                                                      "${detail.total ?? 0}",
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF2D3748),
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        isDense: true,
                                                      ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  onChanged: (val) {
                                                    final num =
                                                        int.tryParse(val) ?? 0;
                                                    context
                                                        .read<SettlementBloc>()
                                                        .add(
                                                          UpdateDetail(
                                                            idPayment: state
                                                                .activeTabId,
                                                            idNasabah: cust.id,
                                                            total: num,
                                                            value:
                                                                num *
                                                                detail
                                                                    .billingValue!,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final currentQty =
                                                      detail.total ?? 0;
                                                  final newQty = currentQty + 1;
                                                  context
                                                      .read<SettlementBloc>()
                                                      .add(
                                                        UpdateDetail(
                                                          idPayment:
                                                              state.activeTabId,
                                                          idNasabah: cust.id,
                                                          total: newQty,
                                                          value:
                                                              newQty *
                                                              detail
                                                                  .billingValue!,
                                                        ),
                                                      );
                                                },
                                                child: Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1565C0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            const Color(
                                                              0xFF1565C0,
                                                            ).withValues(
                                                              alpha: 0.25,
                                                            ),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.add_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xFFEDF2F7),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Subtotal Tiket:",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF718096),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            StringFormatter().idrFormatter(
                                              (detail.total ?? 0) *
                                                  detail.billingValue!,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF1565C0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}
