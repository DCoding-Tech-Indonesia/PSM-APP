import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/history/history_list_card.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  String _activeTab = "Pending";

  static const List<String> _tabs = [
    "Pending",
    "Cancel",
    "Selesai",
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  Future<void> _onRefresh() async {
    final bloc = context.read<SettlementBloc>();

    bloc.add(PageDashboardLoad());

    await bloc.stream.firstWhere(
          (state) => state.status != SettlementStatus.loading,
    );
  }


  void _changeTab(String tab) {
    final index = _tabs.indexOf(tab);

    if (_activeTab == tab) return;

    setState(() {
      _activeTab = tab;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }


  List filterData(
      List data,
      String tab,
      ) {
    return data.where((item) {
      final code = item.status.code;

      switch (tab) {
        case "Pending":
          return code == "DFT";

        case "Cancel":
          return code == "CNC";

        case "Selesai":
          return code == "APR";

        default:
          return false;
      }
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status,

      listener: (context, state) {

        if (state.status == SettlementStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: "Gagal melakukan submit draft",
            type: SnackbarType.warning,
          );
        }


        if (state.status == SettlementStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: "Draft berhasil di submit",
            type: SnackbarType.success,
          );

          context
              .read<SettlementBloc>()
              .add(PageDashboardLoad());
        }
      },


      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {

              return Stack(
                children: [

                  Column(
                    children: [

                      CoreHeader(
                        title: "History Settlement",
                        customBgColor: Colors.white,
                        withBorder: true,
                      ),



                      Row(
                        children: _tabs.map((tab) {

                          final active =
                              _activeTab == tab;


                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                _changeTab(tab);
                              },


                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 250),

                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),


                                decoration:
                                BoxDecoration(
                                  border: Border(
                                    bottom:
                                    BorderSide(
                                      width: 3,
                                      color: active
                                          ? Colors.blue
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),


                                child: Center(
                                  child:
                                  AnimatedDefaultTextStyle(
                                    duration:
                                    const Duration(
                                      milliseconds: 250,
                                    ),

                                    style: TextStyle(
                                      color: active
                                          ? Colors.blue
                                          : Colors.grey,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontSize: 16,
                                    ),

                                    child: Text(tab),
                                  ),
                                ),
                              ),
                            ),
                          );

                        }).toList(),
                      ),




                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,

                          onPageChanged: (index) {
                            setState(() {
                              _activeTab =
                              _tabs[index];
                            });
                          },


                          itemCount: _tabs.length,


                          itemBuilder: (context, index) {

                            final tab =
                            _tabs[index];


                            final filtered =
                            filterData(
                              state.listTaskAuditTrail,
                              tab,
                            );


                            return RefreshIndicator(
                              onRefresh: _onRefresh,

                              child: filtered.isEmpty

                                  ? ListView(
                                physics:
                                const AlwaysScrollableScrollPhysics(),

                                children: const [

                                  SizedBox(
                                    height: 200,
                                  ),

                                  Center(
                                    child: Text(
                                      "Tidak ada data",
                                      style:
                                      TextStyle(
                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )


                                  : ListView.separated(
                                physics:
                                const AlwaysScrollableScrollPhysics(),

                                padding:
                                const EdgeInsets.fromLTRB(
                                  26,
                                  20,
                                  26,
                                  20,
                                ),

                                itemCount:
                                filtered.length,


                                separatorBuilder:
                                    (_, __) =>
                                const SizedBox(
                                  height: 12,
                                ),


                                itemBuilder:
                                    (context, i) {

                                  return HistoryListCard(
                                    data:
                                    filtered[i],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),




                  if (state.status ==
                      SettlementStatus.loading)

                    Positioned.fill(
                      child: Container(
                        color:
                        Colors.black.withValues(
                          alpha: .15,
                        ),

                        child: const Center(
                          child:
                          CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}