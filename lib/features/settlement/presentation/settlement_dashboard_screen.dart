import 'package:advanced_salomon_bottom_bar/advanced_salomon_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/cubit/core_tab_cubit.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_nav_widget.dart';
import 'package:psm_mobile/core/presentations/widgets/core_profile_screen_menu.dart';
import 'package:psm_mobile/core/router/route_observer.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/features/dashboard/presentation/screens/home_screen_menu.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class SettlementDashboardScreen extends StatefulWidget {
  final SharedPreferencesService sharedPreferencesService;

  const SettlementDashboardScreen({
    super.key,
    required this.sharedPreferencesService,
  });

  @override
  State<SettlementDashboardScreen> createState() =>
      _SettlementDashboardScreenState();
}

class _SettlementDashboardScreenState
  extends State<SettlementDashboardScreen> with RouteAware {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    context.read<SettlementBloc>().add(PageDashboardLoad());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: BlocBuilder<CoreTabCubit, int>(
        builder: (context, state) {
          return CoreBottomNavWidget(
            currentIndex: state,
            onTap: (index) {
              context.read<CoreTabCubit>().changeTab(index);
            },
            items: [
              AdvancedSalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: theme.primaryColor,
                unselectedColor: theme.disabledColor,
              ),
              AdvancedSalomonBottomBarItem(
                icon: const Icon(Icons.person),
                title: const Text("Profile"),
                selectedColor: theme.primaryColor,
                unselectedColor: theme.disabledColor,
              ),
            ],
          );
        },
      ),

      body: BlocBuilder<CoreTabCubit, int>(
        builder: (context, state) {
          switch (state) {
            case 0:
              return const HomeScreenMenu();
            case 1:
              return CoreProfileScreenMenu(
                sharedPreferencesService: widget.sharedPreferencesService,
              );
            default:
              return const Center(child: Text("Unknown Tab"));
          }
        },
      ),

      floatingActionButton: BlocBuilder<CoreTabCubit, int>(
        builder: (context, state) {
          if (state == 0) {
            return FloatingActionButton(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () {
                context.push('/settlement/form');
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}